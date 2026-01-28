# EE4218 Lab Manuals

Welcome to the exciting world of embedded systems. We have prepared a series of labs for this course to give you hands-on experience in Hardware/Software Co-design. Each lab consists of two parts: 1) the first part consists of a tutorial with step-by-step guidance and 2) the second part is an assignment to allow students to use practical knowledge gained from the first part to solve a fairly simple design and implementation problem.

!!! warning "Follow the Spirit"
    Some screenshots in the manuals may be taken on other versions of Vivado/Vitis or for other configurations. The instructions could also vary slightly depending on the exact design/configuration you follow. The spirit of the instructions remain the same. Understand the significance of each step rather than following it mechanically - **understand why you are doing what you are doing**.

## Lab Info

### Lab Venue

Lab Venue : Digital Electronics Lab (E4 level 3) - Outreach Room

### Lab Description

| Lab | Description | Weight | Remarks |
|-------|---------------|---------------------------------------------------------------|-----------|
| 1 | Introduction to Hardware Design | 7% |  |
| 2 | Introduction to Hardware/Software Co-design | 7% |  |
| 3 | Integrating the Co-processor | 7% |  |
| 4 | High-Level Synthesis | 7% |  |
| 5 | Mini Project | 22% | 2% for Progress Evaluation 20% for Final Demo |

### Lab Schedule

| Week | Date | Activity | Remarks |
|-------|---------------|---------------------------------------------------------------|-----------|
| 3 | 28 Jan, 30 Jan | Lab 1 Intro |  |
| 4 | 4 Feb, 6 Feb | Lab 1 Consultation, Lab 2 Intro |  |
| 5 | 11 Feb, 13 Feb | **Lab 1 Demo**, Lab 2 Consultation |  |
| 6 | 18 Feb | **Lab 2 Deadline**, Lab 3 Intro | Submission of files to Canvas due on **18 Feb** for **everyone**. Evaluation will be along with Lab 3 in Week 7. Lab 3 Intro only on Friday - recording will be made available |
| Recess | No session | Work on Lab 3 |  |
| 7 | 4 Mar, 6 Mar | **Lab 2&3 Demo**, Lab 4 Intro |  |
| 8 | 11 Mar, 13 Mar | Project Intro |  |
| 9 | 18 Mar, 20 Mar | **Lab 4 Demo**, Project Consultation |  |
| 10 | 25 Mar, 27 Mar | **Project Progress Evaluation** and Consultation |  |
| 11 | 1 Apr | Project Consultation (Wed only) |  |
| 12 | 8 Apr, 10 Apr | **Project Demo** |  |

### Kria Board

You will be provided a Kria KV260 SOM Vision Starter Kit containing a Xilinx Zynq Ultrascale+ SoC. More information about the board can be found at <https://www.xilinx.com/products/som/kria/kv260-vision-starter-kit/kv260-getting-started/getting-started.html> (scroll down).

#### Board Handling Guidelines

Like most development boards and PCBs, your FPGA board is fragile. Treat it with care and respect, as if it were your own. It is reasonably expensive at over S$500, and not so easy to get replaced.

Here are some tips to take good care of your board:

* Do not touch the PCB tracks, or the components on the board. Static discharge can damage or destroy electronic components, and these boards can be particularly susceptible.
* Use the nice plastic box with foam lining to transport your FPGA board. Do not use a plastic bag or other plastic container to carry your boards, and most certainly don't put it bare in your backpack/tote/briefcase/whatever you bring to class.
* When using the board, keep it on a stable, flat surface. Do NOT have it hanging off the USB cable, or hanging off the edge of a table, or on your lap, or anywhere that isn't a suitable, solid surface.
* Absolutely DO NOT DROP your board. When moving it around, hold the board by the edges and make sure the USB cable is unplugged so as to minimize strain on the port and to avoid it getting caught on something.
* Avoid plugging and unplugging the micro-USB cable more than necessary. To reset the board, you can use the power switch on the top left of the board, or unplug the USB-A connector from your computer if really necessary. Micro USB is a notoriously fragile connector, and it's best to avoid putting more strain on it than necessary. USB-A is much sturdier so that end of the cable is not as much of a concern.
* Apply common sense and standard practices for taking care of electronics: don't eat or drink near your board in case you get crumbs (or worse, a spill) on the board. Don't throw the board around. Plug and unplug accessories with care. Be gentle when using the switches and buttons.

## Policies

### Late demo / submission policy

For each assessment, you **must** demonstrate on the stipulated date during your schedule time slot as given in the assessment schedule. If you don't, you get a **0 mark** for that lab!

You are supposed to submit your codes to Canvas by the deadline for uploading - if you submit after the deadline, there will be a **10% penalty** in marks. 
The codes submitted should be *the same codes used for evaluation*. Any bug fixes/improvements after the demo could you useful for future labs and project, but will not result in an increase in marks after the demo - in fact, a mismatch could result in a penalty.

A late demo is allowed (with no penalty) only if you can produce documented evidence to justify the late demo/submission - in such a case, please let us know immediately as and when such a situation arises.

### Email policy

Kindly *DO NOT send emails regarding labs* wherever possible. Post see below on how to get help. Only if the matter is personal / administrative, please contact the lecturer via Canvas Inbox (not emails).

### How to get help

If you have any questions regarding the content of the labs, please follow these steps, *in this order*, to answer them.  

1. Please read the lab manual closely. We will try our best to keep the manual updated with any common errors, or issues, that you may face.

2. If the lab manual does not answer your question, [the GitHub repository](https://github.com/nus-EE4218/labs) has a [discussions page](https://github.com/NUS-EE4218/labs/discussions). Please search here for your question, in case it has already been answered before. We will leave questions and answers from previous semesters on this page, so over time, more and more information should be covered between here and the manuals.

3. If you cannot find an answer to your question in the discussions either, then please create a new discussion. Make sure your title is as succinct, but descriptive, as possible, for the benefit of others who may search the page later. Also, do make sure you include all relevant details in the discussion content. [This webpage](https://www.freecodecamp.org/news/how-to-ask-good-technical-questions/) offers some helpful advice on how to ask good technical questions.

4. Please **DO NOT** send emails to the teaching staff asking technical questions regarding the lab activities. We will ignore all such emails, with no exception. Post all technical questions to the discussions page. This benefits others, because anyone who has the issue in the future can solve it quickly with a search. It also benefits you, because you may receive an answer faster from a classmate, than from us.

On that subject, please do join in and help each other out in the discussions as far as possible.

### Fair Use of LLMs and Open Source Code

It is ok to rely on LLMs or other online code in moderation. However, you should

* Understand the code in detail and be able to explain it.
* Not infringe anyone's copyright, i.e., it should be code released under an open-source/permissive license. 
* Demarcate such code clearly, and give proper attribution to the source/LLM, along with the prompts used. Using AI-generated code without attribution is considered plagiarism.

Discussions are encouraged, but 'we had discussed' is not a valid excuse if your codes turn out to be uncomfortably similar to that of another group (except when you use online code with attribution as mentioned above).

Though there will be intra-team differentiation in marks according to the contribution levels, a team will be collectively responsible for plagiarized code. Your teammates might be better off with no contribution at all from you than to receive plagiarized code.

## Updates

------------------------------------

------------------------------------

## License

 [NUS EE4218 Lab Manuals](https://github.com/nus-EE4218/labs) © 2024 by [NUS EE4218 Team](https://github.com/nus-EE4218) is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1)  
