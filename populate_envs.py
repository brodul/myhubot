import configparser
import os
import unittest
import tempfile
import textwrap


def main(config_file='hubot_secrets.ini'):

    config = configparser.ConfigParser()

    config.read(config_file)

    for k, v in config['environment'].items():
        os.environ[k.upper()] = v
    for section in config.sections():
        for k, v in config[section].items():
            os.environ[str('%s_%s' % (section, k)).upper()] = v


class TestNoEnvironmentSection(unittest.TestCase):
    def setUp(self):
        self.ini_file = tempfile.mkstemp()[1]
        self.ini_content = textwrap.dedent("""\
            [baz]
            foo=bar
        """)
        with open(self.ini_file, 'w') as f:
            f.write(self.ini_content)

    def tearDown(self):
        os.unlink(self.ini_file)

    def test_no_section(self):
        self.assertRaises(Exception, main, self.ini_file)


class TestEnvironmentSection(unittest.TestCase):
    def setUp(self):
        self.ini_file = tempfile.mkstemp()[1]
        self.ini_content = textwrap.dedent("""\
            [environment]
            foo=bar

            [baz]
            user=brodul
        """)
        with open(self.ini_file, 'w') as f:
            f.write(self.ini_content)

        main(self.ini_file)

    def tearDown(self):
        os.unlink(self.ini_file)

    def test_set_without_section(self):
        self.assertIn('FOO', os.environ)
        self.assertEqual(os.environ['FOO'], 'bar')

    def test_set_with_section(self):
        self.assertIn('ENVIRONMENT_FOO', os.environ)
        self.assertEqual(os.environ['ENVIRONMENT_FOO'], 'bar')


class TestGeneralSection(unittest.TestCase):
    def setUp(self):
        self.ini_file = tempfile.mkstemp()[1]
        self.ini_content = textwrap.dedent("""\
            [environment]
            foo=bar

            [baz]
            user=brodul
        """)
        with open(self.ini_file, 'w') as f:
            f.write(self.ini_content)

    def tearDown(self):
        os.unlink(self.ini_file)

    def test_section(self):
        self.assertIn('BAZ_USER', os.environ)
        self.assertEqual(os.environ['BAZ_USER'], 'brodul')


if __name__ == '__main__':
    main()
