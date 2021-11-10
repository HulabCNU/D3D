# D3D
A dynamical 3D reconstruction algorithm using multiple Orbbec RGBd cameras with implementation on Jetson Nano 2GB. This is for the 2021 Orbbec 3D development competition.

# Demo

Input: 2D images (RGB or RGBd) captured by fixed multiple cameras (one camera is also OK).

Output: 3D video = reconstructed 3D model (a dynamical surface) + moving trajectory.

# Algorithm

1. 2D image collection.

2. Component-wise mask.

3. Multi-view stereo.

4. World coordinate re-projecting.

# PC implementation (Ubuntu 18.04)

# Jetson Nano 2GB Implementation
