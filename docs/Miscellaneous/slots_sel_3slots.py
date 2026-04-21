import numpy as np
import pandas as pd
from itertools import combinations

# 9 columns corresponding to 9 proposed slots.
# rows corresponding to responses from students.
# The code is not well-commented and no optimization has been attempted.

labels = np.array([
    'Monday AM', 'Tuesday AM', 'Wednesday AM', 'Wednesday PM',
    'Thursday AM', 'Thursday PM', 'Friday AM', 'Friday PM'
])

# Read CSV safely (handles headers, BOM, blanks better)
df = pd.read_csv('Canvas_Responses.csv')
table = df.fillna(0).astype(int).values  # ensure numeric
n, m = table.shape

# Number of 3-slot combinations
num_triplets = m * (m - 1) * (m - 2) // 6

scores = np.zeros(num_triplets, dtype=int)
slots_i = np.zeros(num_triplets, dtype=int)
slots_j = np.zeros(num_triplets, dtype=int)
slots_k = np.zeros(num_triplets, dtype=int)

# Compute scores
index = 0
for i, j, k in combinations(range(m), 3):
    slots_i[index] = i
    slots_j[index] = j
    slots_k[index] = k
    
    # Vectorised OR over three columns
    scores[index] = np.sum(
        np.logical_or.reduce((table[:, i], table[:, j], table[:, k]))
    )
    index += 1

# Sort in descending order
sorted_idx = np.argsort(-scores)

# Display results
for idx in sorted_idx:
    print(
        f"{scores[idx]} | "
        f"{labels[slots_i[idx]]} | "
        f"{labels[slots_j[idx]]} | "
        f"{labels[slots_k[idx]]}"
    )
