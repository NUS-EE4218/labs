import numpy as np
import pandas as pd

# 8 columns corresponding to 8 proposed slots.
# rows corresponding to responses from students.
# The code is not well-commented and no optimization has been attempted.

# Labels for the slots
labels = np.array([
    'Monday AM', 'Tuesday AM', 'Wednesday AM', 'Wednesday PM',
    'Thursday AM', 'Thursday PM', 'Friday AM', 'Friday PM'
])

# Read the CSV file using pandas
df = pd.read_csv('Canvas_Responses.csv')
table = df.values.astype(int)  # Convert to a numeric numpy array
n, m = table.shape  # n = number of students, m = number of slots

# Initialize arrays
num_pairs = m * (m - 1) // 2
scores = np.zeros(num_pairs, dtype=int)
scores_i = np.zeros(num_pairs, dtype=int)
scores_j = np.zeros(num_pairs, dtype=int)

# Compute scores for each pair of slots
index = 0
for i in range(m):
    for j in range(i + 1, m):
        # Store the slot indices
        scores_i[index] = i
        scores_j[index] = j
        
        # Count how many students responded to at least one of the two slots
        scores[index] = np.sum(np.logical_or(table[:, i], table[:, j]))
        
        index += 1

# Sort scores in descending order
sorted_indices = np.argsort(-scores)  # minus for descending
sorted_scores = scores[sorted_indices]
sorted_i = scores_i[sorted_indices].astype(int)
sorted_j = scores_j[sorted_indices].astype(int)

# Display results
for s, i_idx, j_idx in zip(sorted_scores, sorted_i, sorted_j):
    print(f"{s} | {labels[i_idx]} | {labels[j_idx]}")

