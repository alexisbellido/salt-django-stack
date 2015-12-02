from fabric.api import run, sudo

def salt_ping():
    sudo("salt '*' test.ping")
