all: examples

examples:
		sed 's/=.*$$/= XXXXXX/g' hubot_secrets.ini > hubot_secrets.ini.example
