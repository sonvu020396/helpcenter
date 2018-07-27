app:
	docker rm -f HelpCenter; docker-compose run --name HelpCenter --rm -p 6000:4000 web iex -S mix phoenix.server
bash:
	docker-compose run --rm web bash