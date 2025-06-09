-- Cleanup script to remove all seeded data from the database
-- This script removes data in reverse order to respect foreign key constraints

-- Company 3
DELETE FROM session_signing_keys WHERE project_id = '8d274edd-bca0-4bc2-862c-ecd3f22669f0';
DELETE FROM users WHERE email = 'user1@company3.example.com';
DELETE FROM project_ui_settings WHERE project_id = '8d274edd-bca0-4bc2-862c-ecd3f22669f0';
DELETE FROM project_trusted_domains WHERE project_id = '8d274edd-bca0-4bc2-862c-ecd3f22669f0';
UPDATE projects SET organization_id = NULL WHERE id = '8d274edd-bca0-4bc2-862c-ecd3f22669f0';
DELETE FROM organizations WHERE id = '0fbcb562-5f18-40e3-8725-47fcc8209af1';
DELETE FROM projects WHERE id = '8d274edd-bca0-4bc2-862c-ecd3f22669f0';

-- Company 2
DELETE FROM session_signing_keys WHERE project_id = '24ba0dd5-e178-460e-8f7a-f3f72cf6a1e7';
DELETE FROM users WHERE email = 'user1@company2.example.com';
DELETE FROM project_ui_settings WHERE project_id = '24ba0dd5-e178-460e-8f7a-f3f72cf6a1e7';
DELETE FROM project_trusted_domains WHERE project_id = '24ba0dd5-e178-460e-8f7a-f3f72cf6a1e7';
UPDATE projects SET organization_id = NULL WHERE id = '24ba0dd5-e178-460e-8f7a-f3f72cf6a1e7';
DELETE FROM organizations WHERE id = '8b5972b6-c878-4c6c-a351-9e01da20f776';
DELETE FROM projects WHERE id = '24ba0dd5-e178-460e-8f7a-f3f72cf6a1e7';

-- Company 1
DELETE FROM session_signing_keys WHERE project_id = '7abd6d2e-c314-456e-b9c5-bdbb62f0345f';
DELETE FROM users WHERE email = 'user1@company1.example.com';
DELETE FROM project_ui_settings WHERE project_id = '7abd6d2e-c314-456e-b9c5-bdbb62f0345f';
DELETE FROM project_trusted_domains WHERE project_id = '7abd6d2e-c314-456e-b9c5-bdbb62f0345f';
UPDATE projects SET organization_id = NULL WHERE id = '7abd6d2e-c314-456e-b9c5-bdbb62f0345f';
DELETE FROM organizations WHERE id = '8648d50b-baa1-4929-be0f-bc7238f685ab';
DELETE FROM projects WHERE id = '7abd6d2e-c314-456e-b9c5-bdbb62f0345f';

-- Dogfood Project
DELETE FROM session_signing_keys WHERE project_id = '56bfa2b3-4f5a-4c68-8fc5-db3bf20731a2';
DELETE FROM backend_api_keys WHERE project_id = '56bfa2b3-4f5a-4c68-8fc5-db3bf20731a2';
DELETE FROM project_ui_settings WHERE project_id = '56bfa2b3-4f5a-4c68-8fc5-db3bf20731a2';
DELETE FROM users WHERE email = 'root@app.tesseral.example.com';
DELETE FROM project_trusted_domains WHERE project_id = '56bfa2b3-4f5a-4c68-8fc5-db3bf20731a2';
UPDATE projects SET organization_id = NULL WHERE id = '56bfa2b3-4f5a-4c68-8fc5-db3bf20731a2';
DELETE FROM organizations WHERE id = '7a76decb-6d79-49ce-9449-34fcc53151df';
DELETE FROM projects WHERE id = '56bfa2b3-4f5a-4c68-8fc5-db3bf20731a2';