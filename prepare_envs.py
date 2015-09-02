import configparser
import os

def main(config_file='hubot_secrets.ini'):

    config = configparser.ConfigParser()

    config.read(config_file)

    for k, v in config['environment'].items():
        print("%s=%s" % (k.upper(), v))
    for section in config.sections():
        for k, v in config[section].items():
            var_name = str('%s_%s' % (section, k)).upper()
            print("%s=%s" % (var_name, v))


if __name__ == '__main__':
    main()
