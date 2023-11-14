# SwarMer

## Setup

``bash setup.sh``


## Run
Ideally, SwarMer requires a total number of processing cores greater then or equal to the number of points in the point cloud (number of FLSs).

Edit configurations in `config.py` then run the following:

``python server.py``

## Large Point Clouds
If you encountered an error regarding not enough fds, increase max open files system-wide to be able to run a large point cloud:

``sudo vim /etc/sysctl.conf``

Add the following line:

``fs.file-max = 9999``

``sudo sysctl -p``

reload terminal and then run this command:

``ulimit -n 9999``
