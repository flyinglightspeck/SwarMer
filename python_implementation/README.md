# SwarMer Python Implementation

## Running on a Laptop or a Server

This software was implemented and tested using Python 3.9.0.

We recommend using PyCharm, which enables the software to run across multiple operating systems, e.g., Windows, MacOS, etc.

## Running using a (PyCharm) Terminal

Run ``bash setup.sh`` to install the requirements.

The variables specified in `config.py` control settings.  

If running on a laptop/server with a limited number of cores, use a point cloud with a few points.  As a general guideline, their values should not exceed four times the number of physical cores.

This program is designed to scale horizontally across multiple servers and run with large point clouds. Each point is assigned to a Flying Light Speck, a process launched by this program.  

Run `server.py` after adjusting the settings of `config.py` (see below). 

## Running using virtual environment, Venv

You can create and activate a virtual environment by following these steps.
First, you'll need to create a virtual environment using Venv. You can use any name instead of env.

```
cd SwarMer
python3.9 -m venv env
```

Then, activate the virtual environment.

```
source env/bin/activate
```

On Windows use the following instead:

```
env/Scripts/activate.bat //In CMD
env/Scripts/Activate.ps1 //In Powershel
```

Install the requirements:

```
pip3 install -r requirements.txt
```

You can now run `server.py`. Finally, the virtual environment can be deactivated by running `deactivate` in the terminal.


## A Point Cloud
We provide several point clouds, e.g., a Chess piece.  The value of variable SHAPE in config.py controls the used point cloud.  Set the `SHAPE` value to the shape name (use the file name of .mat files in the `assets` directory as the value of the `SHAPE`, e.g., `teapot`).  The repository comes with the following shapes: `chess`, `dragon`, `statue`, `racecar`, `skateboard`, `hat`, `teapot`, `cat`, `butterfly`.

# Running on Multiple Servers: Amazon AWS
First, set up a cluster of servers. Ideally, the total number of cores of the servers should equal or be greater than the number of points in the point cloud (number of FLSs).

Set up a multicast domain (For more information on how to create a multicast domain, see aws docs: https://docs.aws.amazon.com/vpc/latest/tgw/manage-domain.html)

Add your instances to the multicast domain. Use the value of MULTICAST_GROUP_ADDRESS in the constants.py for the group address.

Ensure you allow all UDP, TCP, and IGMP(2) traffic in your security group.

After setting up AWS:

Choose one of the instances as the primary instance.

Set the private IP address of the primary instance as the `SERVER_ADDRESS` in `constants.py`.

In `aws_vars.sh`, set `N` to the number of total instances you have. Set the `KEY_PATH` as the path to the AWS key pair on your machine. List the private IP addresses of all the instances in `HOSTNAMES`; the primary should be the first.

Configure the experiment(s) you want to run by modifying `gen_conf.py`.

Clone the repository and set up the project by running `setup.sh` on each server. Then copy the AWS key to the primary instance.

Finally, the experiments will be started by running nohup_run.sh on the primary instance.

```
bash nohup_aws_run.sh
```
