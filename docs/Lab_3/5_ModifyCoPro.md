# Modifying the Coprocessor

Once you update your IP using HLS and come back to your main Vivado project, it will show a banner that 'IP Catalog is Out of Date' or 'myip_0 should be upgraded'. If it is the former, click **Rerun** in the IP Status Tab below. If it is the latter, clicking Report IP Status / Show IP Status will open up the IP Status Tab. Either way, after myip_0 is selected, click **Upgrade Selected**.

If the 'IP Status' tab does not appear, make sure that the IP Integrator is selected in the Flow Navigator, and Reports (top menu bar) > Report IP Status.

An IP Upgrade Completed will pop up once the IP is successfully upgraded. When you dismiss the message by clicking OK, it will show up a Generate Output Products window. Click **Generate**. Once the output products are generated, click OK to dismiss the message.  The IP Status will again show that one or more IPs have changed. Click **Rerun**again (the second time is for regenerating reports), but you need not (and won't be able to) click Upgrade Selected this time.

You can check if the IP is updated by following the screenshot below.

![](ModifyCoPro/ModifyCoPro_VivadoSources.png)

Now, you can go ahead and**Generate Bitstream**.

Once the hardware is generated, Export > **Export Hardware**. Don't forget to **Include bitstream**.

However, a new .xsa file will not cause the platform project to be modified automatically.

## Vitis

In Vitis, select the Switch / re-read XSA option as shown in the screenshot below. You will be required to browse to the updated file followed by select/OK. It will take a short while to re-read the .xsa file.

Once this is done, build the platform project again.

![ModifyCoPro_Vitis_Select_New_XSA](ModifyCoPro/ModifyCoPro_Vitis_Select_New_XSA.png)

If you run into issues, Regenerate BSP as shown in the screenshot below.

![ModifyCoPro_VitisRegenerateBSP](ModifyCoPro/ModifyCoPro_VitisRegenerateBSP.png)

If that doesn't work either, create a new workspace, and then an application project using the new .xsa file. Copy over your C code to the new project.

If it still shows the old coprocessor functionality, you might want to try deleting intermediate files in Vivado and regenerating the bitstream.

## Vitis Classic

For Vitis Classic, right-click on the hardware platform as shown in the figure below. You will be required to browse to the updated .xsa file, followed by two OKs.

![](ModifyCoPro/ModifyCoPro_VitisExplorer.png)

Then build the platform project (e.g., design_1_wrapper).

![](ModifyCoPro/ModifyCoPro_VitisExplorer_Build.png)

The Vitis Classic project doesn't always get updated that properly. If you run into issues, Reset BSP Sources as shown in the figure below, and build the hardware and application projects.

![](ModifyCoPro/ModifyCoPro_VitisResetBSP.png)

If that doesn't work either, create a new workspace, and then an application project using the new .xsa file. Copy over your C code to the new project.

Don't forget to **program the FPGA again** before running your code (which will be done automatically if the option to Program FPGA is checked in Run Configurations), as the hardware has now changed!

If it still shows the old coprocessor functionality, you might want to try deleting intermediate files in Vivado and regenerating the bitstream.
