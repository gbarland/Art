"""
==============
Normalized Cut
==============

This example constructs a Region Adjacency Graph (RAG) and recursively performs
a Normalized Cut on it [1]_.

References
----------
.. [1] Shi, J.; Malik, J., "Normalized cuts and image segmentation",
       Pattern Analysis and Machine Intelligence,
       IEEE Transactions on, vol. 22, no. 8, pp. 888-905, August 2000.
"""

import os
from skimage import io, data, segmentation, color
from skimage.future import graph
from matplotlib import pyplot as plt


script_dir = os.path.dirname(__file__)
rel_path = "images/obama.jpg"
file_path = os.path.join(script_dir, rel_path)

img = io.imread(file_path)
plt.imshow(img)
plt.show()

labels1 = segmentation.slic(img, compactness=30, n_segments=500)
out1 = color.label2rgb(labels1, img, kind='avg')

plt.imshow(out1)
plt.show()
