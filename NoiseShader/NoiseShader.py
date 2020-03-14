
import os
from skimage import io, data, segmentation, color
from skimage.future import graph
from matplotlib import pyplot as plt


script_dir = os.path.dirname(__file__)
rel_path = "images/k9.jpg"
file_path = os.path.join(script_dir, rel_path)

img = io.imread(file_path)
plt.imshow(img)

labels1 = segmentation.slic(img, compactness=10, n_segments=2000, sigma=0)
labels2 = segmentation.felzenszwalb(img, scale=100, sigma=.3, min_size=50)
out1 = color.label2rgb(labels1, img, kind='avg')
out2 = color.label2rgb(labels2, img, kind='avg')

plt.imshow(out1)
plt.show()
plt.imshow(out2)
plt.show()
