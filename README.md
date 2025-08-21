# Perturbed Oil and Vinegar Signature Schemes

SageMath implementation and study of the "Oil and Vinegar" (OV) and perturbed "OV $\widehat{+}$" post-quantum signature schemes.

This project was created for a Master's research course.

## What's Inside

  * **`src/`**: SageMath implementations.
      * `OV/`: The classic OV scheme, including the Kipnis-Shamir key forgery attack.
      * `OV+/`: The perturbed OV$hat(+)$ scheme, designed to be more secure.
  * **`report/`**: A detailed report (`report.typ`) with security analysis, complexity, and performance benchmarks.
  * **`articles/`**: The research papers this project is based on.

## How to Run

**Prerequisite:** [SageMath](https://www.sagemath.org/)

To run the performance and functionality tests, execute the demo scripts from the project root:

```bash
# Test the classic OV scheme and the attack
sage src/OV/demo.sage

# Test the perturbed OV+ scheme
sage src/OV+/demo.sage
```
