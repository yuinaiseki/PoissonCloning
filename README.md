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

## 📄 Paper
The final project paper can be found at: https://github.com/yuinaiseki/PoissonCloning/blob/main/CSC262_PoissonImageEditing.pdf

## 👥 Contributions
**Yuina Iseki**:
- Implemented the Poisson equation solver, including the seamless cloning and mixed gradient algorithms. Wrote supporting tools to preprocess input images for Poisson solver. Improved runtime efficiency by optimizing and debugging sparse matrix solving in the algorithm. Conducted experiments on image blending techniques.

**Shuta Shibue**:
- Worked on object and background image dataset preparation, including resizing, creating masks and object outline. Implemented copy-and-paste method. Addressed challenges in transparent object handling and optimized the object detection algorithm. Developed the evaluation criteria. 

Both team members contributed equally to the analysis and writing of the final project paper.

## Acknowledgements
We would like to thank Professor Jerod Weinman and our classmates in CSC262: Computer Vision at Grinnell College for guiding our project and providing feedback. 
https://weinman.cs.grinnell.edu/courses/CSC262/2024F/
