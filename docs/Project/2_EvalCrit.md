# Project Evaluation Criteria, Deliverables

## Evaluation Criteria

The marks below are out of 100, which will be scaled down to 20 marks for eventual grading.

- C-implementation (SOFT): **15** marks
    * 10 marks for running on PC (only if it doesn't run on FPGA board).
    * 15 marks for being able to run on the FPGA board, with a convincing demo.
- HDL implementation (HARD_HDL): **40** marks
    * 10 marks for being able to simulate the hardware convincingly.
    * 10 marks for being able to synthesize without any undesirable warnings (warnings are ok as long as you can explain the reasons for the warnings and convince us that it is acceptable).
    * 10 marks for full functionality on the board.
    * 10 marks for optimization efforts.
- HLS implementation (HARD_HLS): **25** marks
    * 5 marks for being able to do RTL/C cosimulation.
    * 10 marks for being able to run it on the board.
    * 10 marks for appropriate optimization efforts.
- Presentation:**10** marks
- Discretionary component:**10** marks
    * Innovations in design or demo, overall impression.

## List of deliverables

- Presentation: Please make a presentation of **about 3-5 slides** (do not exceed 5) describing the key features/results of your design.
    * Explain the hardware architecture(s), highlighting what you did differently.
    * Compare speed-ups (time taken for Software vs HDL vs HLS versions)
    * Compare hardware utilisations (number of LUTs, FFs, DSPs, etc.) of various implementations.
    * **Do not waste slides** reiterating the problem statement / the original / standard algorithms / obvious stuff.
- Demonstration: The presentation should also include a demonstration to show that your design is working.
    * Showing the speed-ups of various implementations.
    * **The demonstration and presentation should take no more than 10 minutes.**
    * Keep the demo (necessary bitstreams, compiled programs, etc) ready by your time slot. Any delay will result in a penalty.
- Upload design: A zip file containing your design(s) should be made, and the presentation should be included in it.
    * The presentation (ppt/pdf)
    * Include all the source (design files and testbenches - .v/.vhd/.h/.c/.cpp) and data files (.txt/.csv) you have created / modified.
    * .xsa file(s).
    * If the files are different for different designs, give a proper suffix to file names - e.g. design_1_wrapper_HARD_HDL.xsa, test_fifo_myip_v1_0_HARD_HLS.c.
    * DO NOT upload the whole project folder(s).
    * Use the following naming convention for the zip file. Wed/Fri_GroupNum_Project.zip.
    * **The deadline for uploading the zip file is the day of your demo.**
