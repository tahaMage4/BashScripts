#Apache Issue if not install in the 20

`sudo subl /etc/apt/sources.list`

`Add this text into`
#Ubuntu 20.04 LTS (Focal Fossa) -- Full sources.list

`deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse

deb http://archive.canonical.com/ubuntu focal partner
deb-src http://archive.canonical.com/ubuntu focal partner`

sudo apt update 

sudo apt-get install apache2


#for ubaantu 20.04 php issue 
`sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php && sudo apt update`


#for php myadmin issue
`sudo nano /etc/phpmyadmin/apache.conf `
