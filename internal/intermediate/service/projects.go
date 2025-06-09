package service

import (
	"context"
	"fmt"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	intermediatev1 "github.com/tesseral-labs/tesseral/internal/intermediate/gen/tesseral/intermediate/v1"
	"github.com/tesseral-labs/tesseral/internal/store/idformat"
)

func (s *Service) CreateProject(ctx context.Context, req *connect.Request[intermediatev1.CreateProjectRequest]) (*connect.Response[intermediatev1.CreateProjectResponse], error) {
	res, err := s.Store.CreateProject(ctx, req.Msg)
	if err != nil {
		return nil, fmt.Errorf("store: %w", err)
	}

	return connect.NewResponse(res), nil
}

func (s *Service) OnboardingCreateProjects(ctx context.Context, req *connect.Request[intermediatev1.OnboardingCreateProjectsRequest]) (*connect.Response[intermediatev1.OnboardingCreateProjectsResponse], error) {
	res, err := s.Store.OnboardingCreateProjects(ctx, req.Msg)
	if err != nil {
		return nil, fmt.Errorf("store: %w", err)
	}

	accessToken, err := s.AccessTokenIssuer.NewAccessToken(ctx, res.RefreshToken)
	if err != nil {
		return nil, fmt.Errorf("issue access token: %w", err)
	}

	res.AccessToken = accessToken

	// Parse the prod project ID from the response to use for cookies
	prodProjectID, err := idformat.Project.Parse(res.ProdProjectId)
	if err != nil {
		return nil, fmt.Errorf("parse prod project id: %w", err)
	}
	prodProjectUUID := uuid.UUID(prodProjectID)

	expiredIntermediateAccessTokenCookie, err := s.Cookier.ExpiredIntermediateAccessToken(ctx, prodProjectUUID)
	if err != nil {
		return nil, fmt.Errorf("create expired intermediate access token cookie: %w", err)
	}

	refreshTokenCookie, err := s.Cookier.NewRefreshToken(ctx, prodProjectUUID, res.RefreshToken)
	if err != nil {
		return nil, fmt.Errorf("issue refresh token cookie: %w", err)
	}

	accessTokenCookie, err := s.Cookier.NewAccessToken(ctx, prodProjectUUID, accessToken)
	if err != nil {
		return nil, fmt.Errorf("issue access token cookie: %w", err)
	}

	connectRes := connect.NewResponse(res)
	connectRes.Header().Add("Set-Cookie", expiredIntermediateAccessTokenCookie)
	connectRes.Header().Add("Set-Cookie", refreshTokenCookie)
	connectRes.Header().Add("Set-Cookie", accessTokenCookie)

	return connectRes, nil
}
