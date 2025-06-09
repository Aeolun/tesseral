package store

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/stripe/stripe-go/v82"
	stripeclient "github.com/stripe/stripe-go/v82/client"
	"github.com/tesseral-labs/tesseral/internal/common/store/queries"
)

// BootstrapStripeCustomerIDs finds all projects without Stripe customer IDs
// and creates Stripe customers for them. This is useful for development
// environments where projects are seeded without Stripe integration.
func (s *Store) BootstrapStripeCustomerIDs(ctx context.Context, stripeClient *stripeclient.API) error {
	if stripeClient == nil {
		slog.InfoContext(ctx, "bootstrap_stripe_customer_ids_skipped", "reason", "no_stripe_client")
		return nil
	}

	// Test if the Stripe client is properly configured by making a simple API call
	listParams := &stripe.CustomerListParams{}
	listParams.Limit = stripe.Int64(1)
	iter := stripeClient.Customers.List(listParams)
	if iter.Err() != nil {
		// Check if this is an authentication error
		if stripeErr, ok := iter.Err().(*stripe.Error); ok {
			if stripeErr.HTTPStatusCode == 401 {
				slog.InfoContext(ctx, "bootstrap_stripe_customer_ids_skipped", 
					"reason", "stripe_authentication_failed", 
					"error", "Invalid or missing Stripe API key")
				return nil
			}
		}
		slog.WarnContext(ctx, "bootstrap_stripe_customer_ids_validation_failed", "error", iter.Err())
		return nil
	}

	// Find all projects without Stripe customer IDs
	projectsWithoutStripe, err := s.q.GetProjectsWithoutStripeCustomerID(ctx)
	if err != nil {
		return fmt.Errorf("get projects without stripe customer id: %w", err)
	}

	if len(projectsWithoutStripe) == 0 {
		slog.InfoContext(ctx, "bootstrap_stripe_customer_ids_complete", "projects_updated", 0)
		return nil
	}

	slog.InfoContext(ctx, "bootstrap_stripe_customer_ids_starting", "projects_found", len(projectsWithoutStripe))

	for _, project := range projectsWithoutStripe {
		// Create a Stripe customer for this project
		customerParams := &stripe.CustomerParams{
			Name: &project.DisplayName,
			Metadata: map[string]string{
				"tesseral_project_id": project.ID.String(),
				"bootstrap_created":   "true",
			},
		}

		customer, err := stripeClient.Customers.New(customerParams)
		if err != nil {
			// Check if this is an authentication error - if so, stop trying
			if stripeErr, ok := err.(*stripe.Error); ok && stripeErr.HTTPStatusCode == 401 {
				slog.WarnContext(ctx, "bootstrap_stripe_customer_ids_stopped", 
					"reason", "stripe_authentication_failed", 
					"project_id", project.ID,
					"error", "Stripe API key became invalid during bootstrap")
				return nil
			}
			slog.ErrorContext(ctx, "bootstrap_stripe_customer_creation_failed", 
				"project_id", project.ID, 
				"project_name", project.DisplayName, 
				"error", err)
			continue // Continue with other projects instead of failing completely
		}

		// Update the project with the new Stripe customer ID
		err = s.q.UpdateProjectStripeCustomerID(ctx, queries.UpdateProjectStripeCustomerIDParams{
			ID:               project.ID,
			StripeCustomerID: &customer.ID,
		})
		if err != nil {
			slog.ErrorContext(ctx, "bootstrap_stripe_customer_update_failed",
				"project_id", project.ID,
				"project_name", project.DisplayName,
				"stripe_customer_id", customer.ID,
				"error", err)
			continue
		}

		slog.InfoContext(ctx, "bootstrap_stripe_customer_created",
			"project_id", project.ID,
			"project_name", project.DisplayName,
			"stripe_customer_id", customer.ID)
	}

	slog.InfoContext(ctx, "bootstrap_stripe_customer_ids_complete", "projects_processed", len(projectsWithoutStripe))
	return nil
}