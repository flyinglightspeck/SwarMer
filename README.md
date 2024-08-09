# SwarMer

This repository contains MATLAB simulation and a Python implementation of SwarMer, a decentralized localization algorithm.
A short version of the paper describing these implementations is available [here](https://www.holodecks.quest/_files/ugd/fb2888_f3e51e31182f4cd9b61204547b6b89f3.pdf?index=true).  A longer and more complete version is available on [arXiv](https://arxiv.org/pdf/2312.04571).

Authors:  Hamed Alimohammadzadeh(halimoha@usc.edu) and Shahram Ghandeharizadeh (shahram@usc.edu)



## Clone
``git clone https://github.com/flyinglightspeck/SwarMer.git``

## Run
The MATLAB simulation and the Phyton emulation are two independent implementations with their own specific instructions.  Please visit the respective directory of each implementation and follow its instructions.


## Citations

Hamed Alimohammadzadeh and Shahram Ghandeharizadeh. SwarMer: A Decentralized Localization Framework for Flying Light Specks. In the Proceedings of the First International Conference on Holodecks (Holodecks '23), December 15 2023, Los Angeles, California, USA, 10-22. https://doi.org/10.61981/ZFSH2302

```
@inproceedings{alimohammadzadeh2023swarmer,
author = {Alimohammadzadeh, Hamed and Ghandeharizadeh, Shahram}, 
title = {{SwarMer: A Decentralized Localization Framework for Flying Light Specks}},
year = {2023}, 
publisher = {Mitra LLC}, 
address = {Los Angeles, CA, USA}, 
url = {https://doi.org/10.61981/ZFSH2302}, 
doi = {10.61981/ZFSH2302}, 
abstract = {Swarm-Merging, SwarMer, is a decentralized framework to localize Flying Light Specks (FLSs) to render 2D and 3D shapes.  An FLS is a miniature sized drone equipped with one or more light sources to generate different colors and textures with adjustable brightness.  It is battery powered, network enabled with storage and processing capability to implement a decentralized algorithm such as SwarMer.  An FLS is unable to render a shape by itself.  SwarMer uses the inter-FLS relationship effect of its organizational framework to compensate for the simplicity of each individual FLS, enabling a swarm of cooperating FLSs to render complex shapes.  SwarMer is resilient to network packet loss, FLSs failing, and FLSs leaving to charge their battery.  It is fast, highly accurate, and scales to remain effective when a shape consists of a large number of FLSs.},
booktitle = {The First International Conference on Holodecks}, 
numpages = {13}, 
pages = {10--22},
location = {Los Angeles, California}, 
series = {Holodecks '23} 
}
```

## Acknowledgments

This research is supported in part by NSF grant IIS-2232382.  We gratefully acknowledge CloudBank and CloudLab for the use of their resources.
