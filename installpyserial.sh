# Download pyserial to ~/
cd ~/
wget https://github.com/pyserial/pyserial/archive/refs/tags/v3.4.tar.gz -O pyserial-3.4.tar.gz

# Create a temp dir to do the work in
export tmp_dir=~/install_temp/
mkdir $tmp_dir
cd $tmp_dir

# Extract and install pyserial
tar -xvf ~/pyserial*.tar.gz
cd pyserial*
python setup.py install --user

# Clean-up
cd ~/
rm $tmp_dir/ -Rf