—————————————————————————————————————————————————————
MIT License

Copyright (C) 2019 Thilo Weber

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

—————————————————————————————————————————————————————
This directory contains the MATLAB implementation for the paper:

F. Wadehn, T. Weber, D. J. Mack, T. Heldt and H. -A. Loeliger, "Model-Based Separation, Detection, and Classification of Eye Movements," in IEEE Transactions on Biomedical Engineering, vol. 67, no. 2, pp. 588-600, Feb. 2020, https://doi.org/10.1109/TBME.2019.2918986

When using the frame work, please cite:
@ARTICLE{8726166,
  author={Wadehn, Federico and Weber, Thilo and Mack, David J. and Heldt, Thomas and Loeliger, Hans-Andrea},
  journal={IEEE Transactions on Biomedical Engineering}, 
  title={Model-Based Separation, Detection, and Classification of Eye Movements}, 
  year={2020},
  volume={67},
  number={2},
  pages={588-600},
  doi={10.1109/TBME.2019.2918986}}


—————————————————————————————————————————————————————
HOWTO:

The directory contains three use cases of the MBSDC framework:

1. ‚MBSDC_main_simple.m‘ demonstrates its application to a single 1D-recording (horizontal eye position) for sinusoidal SPEM data, rhesus monkey saccade, or simulated data.

2. ‚evaluate_1D_data.m’ demonstrates its application to a dataset of 1D-recordings, including a set of simulated data or a set of monkey-saccades, as well as its evaluation with respect to RMSD, precision/recall, and Cohen’s kappa (where ground truths are available).

3. ‚evaluate_2D_data.m’ demonstrates its application to a dataset of 2D-recordings (horizontal and vertical eye position), in particular, to the annotated dataset used in [2], as well as the evaluation with respect to RMSD, precision/recall, and Cohen’s kappa (where ground truths are available).

—————————————————————————————————————————————————————
DATA:

- The directory contains two examples of sinusoidal SPEM data from [1] as well as a function for generating simulated saccade data.

- The annotated dataset used in [2] can be downloaded from: https://github.com/richardandersson/EyeMovementDetectorEvaluation.

- For examples of monkey saccades with simultaneous single abducens neuron recordings, we refer to [3].

—————————————————————————————————————————————————————
[1] U. J. Ilg. Schuelerlabor Neurowissenschaften. Retrieved on Jan. 2018. [Online]. Available: www.neuroschool-tuebingen-schuelerlabor.de

[2] R. Andersson, L. Larsson, K. Holmqvist, M. Stridh, and M. Nystr¨om,
“One algorithm to rule them all? An evaluation and discussion of ten eye
movement event-detection algorithms,” Behav. Res. Methods, vol. 49,
no. 2, pp. 616–637, Apr. 2017.

[3] M. Prsa, P. W. Dicke, and P. Thier, “The absence of eye muscle
fatigue indicates that the nervous system compensates for non-motor
disturbances of oculomotor function,” J. Neurosci., vol. 30, no. 47, pp.
15 834–15 842, Nov. 2010.