# 🐟 Poisson Cloning: CSC 262 Final Project

**PoissonCloning** attempts seamless and automatic image blending Poisson Image Editing techniques, originally conceived by Perez et al. from Microsoft Research UK.

## ⚙️ Data Setup
Run Setup.m to create matrix files under mat/ folder, which contains the image, logical mask, alpha data, neighbor matrix, etc. They are generated from the datasets under the source/ folder. All codes below rely on these matrix files.

## 🚀 Poisson Blending
- poissonblending.m is the test script which executes copy and paste method, seamless cloning, and mixed gradient seamless cloning.
- currently, the file is set to test these image blending techniques on two images present in the paper:
  - raft object image + ocean background image, and
  - bunny object image + old paper background image.

The output can be found in the testing folder as well as the matlab popup.
The final output images are named 'final_raft.jpg' and 'final_bunny.jpg'

