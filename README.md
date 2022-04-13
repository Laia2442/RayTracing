
# Particle Ray Tracing for Particle Mean Free Path Calculations

This MATLAB code allows the user to quickly track a defined number of particles across a structure that can include pores, grain boundaries, and inclusions.

I worked on this project during my Ph.D. so you can see all the details on my [dissertation] 
(https://escholarship.org/uc/item/0k36t381).
This code or versions of it were used in Chapeters 2 to 4.




## Authors

- [Laia Ferrer-Argemi](https://github.com/Laia2442/)
- [Ziqi Yu](https://www.linkedin.com/in/ziqi-yu-083a3a61/)
- [Hasitha Hewakuruppu](https://www.linkedin.com/in/hasitha-hewakuruppu-71b172147/)


## Deployment

To deploy this project you need to first create your geometry. For example, for circular pores:

```bash
Porosity = 0.50;
UnitCell = [1000,1000]; %this should repeat untill convergence
% unit cell boundaries
x = [-UnitCell(1)/2,UnitCell(1)/2,UnitCell(1)/2,-UnitCell(1)/2,-UnitCell(1)/2];
y = [-UnitCell(2)/2,-UnitCell(2)/2,UnitCell(2)/2,UnitCell(2)/2,-UnitCell(2)/2];
B{1} = [x' y'];

%pores
r = sqrt(Porosity*UnitCell(1)*UnitCell(2)/pi);
theta = linspace(0,2*pi,13);
x = r*cos(theta);
y = r*sin(theta);
B{2} = [x' y'];

save BoundaryData.mat
```

Other geometry examples can be found in Geometries.m
There are two types of boundaries
 - Pore or inclusion boundaries (which are treated the same but pore boundaries should have a 0 transmisison probability)
 - Grain boundaries

Main.m is set as a function so it can be run multiple times with different parameters:
 - TransProb1: transmission probability for pore/inclusion boundaries. Set to 0 for pores.
 - TransProb2: transmission probability for grain boundaries. It should be > 0.
 - B: boundary data for pores/inclusions
 - B1: grain boundary data
 - UnitCell: repeating unit cell
 - por: porosity or any other parameter that you want to iterate over and save in the name of the results file. It does not affect the results, it is only used in the file name.
 - num: how many times the unit cell should repeat. Can do a sweep for a convergence study or set to a sufficiently large number that is known to provide a long-length limit result.

 An example of a study of circular inclusions with varying porosity could be easily run with the above Geometries.m code as
 ```bash
TransProb1=[0:0.1:0.9 0.95];
TransProb2=[];
por=[0.05:0.05:0.2];
num=100;

for i=1:length(TransProb1)
    for j=1:length(por)
        Main(TransProb1,TransProb2,B,B1,UnitCell,por,num);
    end
end
 ```
The result file cointains all the data and results, including
- the pore/inclusion geoemtry,
- the transmissivities used,
- the unit cell used,
- the total simulation length,
- the average number of transmitted particles in % (named as transmissivity),
- and the binary matrix indicating the transmitted/not transmitted result for each particle.
and will be automatically saved as
 ```bash
filename = ['Circles_por',num2str(por),'L_',num2str(UnitCell(1).*num),'.mat'];
save(strcat(filepath,'\DataBank\',filename))
 ```
 Easily change the file name and folder location at the end of Main().
 
 To find the mean free path of the particles, you can use the following expresion where L1 is the total simulation length (check dissertation for explanation)
 ```bash
 mfp_rt = 3/400*L1*Transmissivity;
  ```
Check my other repository for how to use the resulting mean free path to compute the thermal conductivity of nano-structured silicon.

Data Visualization
-
You can visualize your geometry (unit cell) and how it affects your particles "in real time" by using
 ```bash
 ColorKorrect = (Data(:,end) == 1)*[1 0 0];
    
    vel = 20/mean(UnitCell);
    figure('units','normalized','outerposition',[0 0 1 1])
    hold 
    for i = 1:length(B)
    plot(B{i}(:,1),B{i}(:,2),'LineWidth',2,'Color','blue')
    end

   %uncomment if you want to plot the normals for each surface 
%     for i = 1:length(SurfaceNormals)
%     plot([Nv1(i,1) Nv2(i,1)],[Nv1(i,2) Nv2(i,2)],'r')
%     end

    axis square
    grid on
    axis equal
    
    myVideo = VideoWriter('Film 4'); %open video file
    myVideo.FrameRate = 10;  %can adjust this, 5 - 10 works well for me
    open(myVideo)

    for j = 1:qnt
    for k = 1:ceil(Data(j,7)*vel)
        
        plot([Data(j,1) Data(j,1)+Data(j,5)*(Data(j,7)/ceil(Data(j,7)*vel))*k],[Data(j,2) Data(j,2)+Data(j,6)*(Data(j,7)/ceil(Data(j,7)*vel))*k],'Linewidth',2,'Color', ColorKorrect(j,:))
        xlim([-UnitCell(1)/2,UnitCell(1)/2])
        ylim([-UnitCell(2)/2,UnitCell(2)/2])
        pause(0.1)
        frame = getframe(gcf); 
        writeVideo(myVideo, frame);
    end
    end
    close(myVideo)
```
I recommend using less than 5 particles to begin with your project to make sure all boundries are correct and the particle is behaving as intended. 
Trying to run the video with a large number of particles might result in RAM overload.
