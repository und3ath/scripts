Apres installation 

# install common deps. 
apt-get update
apt-get install build-essential gdb strace git autoconf autogen

# Pour un ltrace pas daubé. 
git clone git://git.debian.org/git/collab-maint/ltrace.git 
cd ltrace &&./autogen.sh && ./configure && make && make install 

# Install pwntools
apt-get install python2.7 python-pip python-dev git libssl-dev libffi-dev  build-essential
pip install --upgrade pip
pip install --upgrade pwntools



