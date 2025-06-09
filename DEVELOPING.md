Developing
==========

If you want to work with tesseral on your local machine, there are a few steps to follow.

1. Run `./bin/macos-bootstrap` to ensure all necessary dependencies are installed (mostly, `docker`, `go` and the golang-migrate `migrate` binary). If you have a different OS, look at the commands in that file and run equivalent ones manually. Feel free to contribute bootstrap scripts for a different OS.
3. Build the `api` command.

  - `go build -o api ./cmd/api`

4. Rename or copy `.env.example` to `.env`
5. Run `make bootstrap` which will create all necessary certificates using mkcert, and set up your local docker database.
6. Add the necessary local URL's to your hosts file. You can find a list at `./etc.hosts.example`.
7. Run `docker compose up -d` or (if you enjoy such things) `tilt up`

You can now open https://console.tesseral.example.com and sign in with the dogfood account credentials `root@app.tesseral.example.com` / `password`

When you sign in you'll have to complete a verification challenge over email. You can go to https://smtp.tesseral.example.com to see all the emails sent by our application (obviously this only exists on dev).
