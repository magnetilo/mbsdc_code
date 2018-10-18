—————————————————————————————————————————————————————
MIT License

Copyright (C) 2018 Thilo Weber

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

—————————————————————————————————————————————————————
This directory contains a MATLAB implementation of:

„A Framework for Model-based Separation, Detection, and Classification of Eye Movements,“ Wadehn, Weber, Mack, Ilg, Heldt, Loeliger, 2018

When using the frame work, please cite:
{ bibtex }

—————————————————————————————————————————————————————
HOWTO:

The directory contains three use case examples of the MBSD framework:

1. ‚MBSD_main_simple.m‘ demonstrates the application to a single 1D-recording (horizontal eye position), including the sinusoidal SPEM data, a single monkey-saccade, or simulated data.

2. ‚evaluate_1D_data.m’ demonstrates the application to a data set of 1D-recordings, including a set of simulated data or a set of monkey-saccades, as well as the evaluation with respect to RMSD, precision/recall, and Cohen’s kappa (where ground truths are available).

3. ‚evaluate_2D_data.m’ demonstrates the application to a data set of 2D-recordings (horizontal and vertical eye position), in particular, to the annotated data set from Andersson et. al. 2017, as well as the evaluation with respect to RMSD, precision/recall, and Cohen’s kappa (where ground truths are available).

DATA:

The directory contains two examples of sinusoidal SPEM data as well as a function for generating simulated saccade data.

The annotated data set from Andersson et. al. 2017 can be downloaded from: https://github.com/richardandersson/EyeMovementDetectorEvaluation.

For examples of monkey saccades with simultaneous single abducens neuron recordings, please contact …



