### Lab1 part1

1. What is the difference between a ’control’ **u_t**, a ’measurement’ **z_t** and the state **x_t**? Give examples of each?

   **u_t**:change the state of the system, like motors; **x_t**: describe the statement of the system. z_t: the measurement of the system form sensor like camera, range scan.

$$
u_t = [dx,dy] \quad x_t = [x,y,\theta] \quad z_t = [x,y]
$$



2. Can the uncertainty in the belief increase during an update? Why (or not)?

   No, during the update, 
   $$
   \Sigma_t = (I-K_tC_t) \overline\Sigma_t = (\overline \Sigma_t^{-1}+C_t^{T}Q_t^{-1}C_t)^{-1}
   \\ because:C_t^{T}Q_t^{-1}C_t \quad is \quad simi-define
   $$
   so the covariance updated is smaller the before.

3. During update what is it that decides the weighing between measurements and belief?

   Kalman Gain

4. What would be the result of using a too large a covariance (Q matrix) for the measurement model

   The Q matrix represents the measurement noise covariance. If Q matrix is too big, which means a lager uncertainty.  The Kalman Gain will decrease, so the updated belief will depend on the measurement model in less degree. 

5. What would give the measurements an increased effect on the updated state estimate?

   The Q matrix will decrease, which leads to smaller uncertainty and an increased Kalman Gain. So, during the update process, the updated state will assign more weights on the measurement model.

6. What happens to the belief uncertainty during prediction? How can you show that?

   during prediction, the belief uncertainty will increase, because it considers the process noise and the uncertainty of previous state with the transformation.
   $$
   \overline\Sigma_t = A_t\Sigma_{t-1}A_t^T+R_t
   $$
   we can monitor the covariance, if the covariance grows, the uncertainty increases.

7. How can we say that the Kalman filter is the optimal and minimum least square error estimator in the case of independent Gaussian noise and Gaussian priori distribution? (Just describe the reasoning not a formal proof.)

   First, The Kalman filter is a Bayesian estimator, which uses the prior distribution and the new observational data to produce a posterior distribution. For this linear, independent Gaussian system, the posterior distribution is also a Gaussian distribution. For a Gaussian distribution, the mean and the covariance can be computed precisely.

8. In the case of Gaussian white noise and Gaussian priori distribution, is the Kalman Filter a MLE and/or MAP estimator?

   **MLE:**  Under Gaussian noise, the Kalman filter maximize the likelihood function of the probability of observing the measurements given the state estimates. In this aspect, Kalman filter is a MLE. 

   **MAP:** The Kalman filter is a kind of Bayesian estimator, and it not only consider the likelihood of the measurement data, but also the prior probability distribution of the parameters. So, it also a MAP to maximize the posterior probability.

**Extended Kalman Filter:**

9. How does the extended Kalman filter relate to the Kalman filter?

   The extended Kalman filter is suitable for nonlinear system based on standard Kalman filter. EKF approximates the system as linear around the current estimation by a first-order Taylor series expansion. Both of them have the similar update process.

10. Is the EKF guaranteed to converge to a consistent solution?

    No, here are some factors regarding the convergence of the EKF like the degree of uncertainty and the degree of local nonlinearity of the function that are being approximated. If the degree of uncertainty and local nonlinearity is too big, EKF can't guarantees to converge to a consistent solution. 

11. If our filter seems to diverge often can we change any parameter to try and reduce this?

    yes:

    - we can replace μ_z with a state μ_~ that minimizes when linearize around the point:
      $$
      |h( \tilde \mu - z_t)|^2
      $$

    - adjust the Q and R.

**Localization:**

12. If a robot is completely unsure of its location and measures the range *r* to a know landmark with Gaussian noise what does its posterior belief of its location *p*(*x, y, θ**|**r*) look like? So a formula is not needed but describe it at least.

    It will be a circle around the landmark with distance r, Also, the circle has width regarding to the standard deviation of the measurement noise. And, the θ will remain uniform because of lacking of information of direction.

13. If the above measurement also included a bearing how would the posterior look?

    It will be a elliptical distribution whose major axis would align with the bearing measurement, and the minor axis represent the uncertainty.

14. If the robot moves with relatively good motion estimation (prediction error is small) but a large initial uncertainty in heading *θ* how will the posterior look after traveling a long distance without seeing any features?

    The posterior will have an increasing covariance because of increasing and accumulating uncertainty.

15. If the above robot then sees a point feature and measures range and bearing to it how might the EKF update go wrong?

    This performance of EKF depends on the linearization of the measurement model, which already has a significant error and uncertainty. Also, because of the big covariance at this time, the EFK may be divergent.