function [] = Main(TransProb1,TransProb2,B,B1,UnitCell,por,num)
%tau grains, tau inclusions, geometry, unitcell, and number of repeated
%cells
tic
% load BoundaryData
backscatter = 0;
NumCells = num;
SimulationLength = UnitCell(1)*NumCells;
    
    SurfacePoints = [];
    SurfaceNormals = [];
    SurfaceDisplacements = [];
    Nv1 = [];
    Nv2 = [];
    P1 = [];
    P2 = [];

    for i = 1:length(B)
        SP = [B{i}];
        ds = SP(2:end,:) - SP(1:end-1,:);
        Sn = [-ds(:,2),ds(:,1)]./abs(vecnorm([ds(:,2),-ds(:,1)]')'); % this is the part where the normals are calculated
        nv1 = SP(1:end-1,:);
        nv2 = SP(1:end-1,:) + Sn*5;
        SurfaceDisplacements = [SurfaceDisplacements ;sum(SP(2:end,:).*Sn,2)];
        SurfacePoints = [SurfacePoints ;B{i}];
        SurfaceNormals = [SurfaceNormals; Sn];
        Nv1 = [Nv1;nv1];
        Nv2 = [Nv2;nv2];
        P1 = [P1 ;SP(1:end-1,:)];
        P2 = [P2 ;SP(2:end,:)];
    end
    
SurfaceType=zeros(length(P1),1);
SurfaceType(1:(length(B1)+3))=1;
% SurfaceType((length(B1)+4):end)=2;
    
save SurfaceData

    TotNumParticles = 5e5;%number of phonons
    Number_of_cores = feature('numcores')-1;

    NumParticles = ceil(TotNumParticles/Number_of_cores);
    TotNumParticles = NumParticles*Number_of_cores;
    
%     parfor_progress(TotNumParticles);
    parfor (k = 1:Number_of_cores,Number_of_cores)
        [Data{k},Coll{k}] = MyTraceCombined(NumParticles,TransProb1,TransProb2); %% This is the part where you point to the function 
    end
%     parfor_progress(0);
    
    Transmissivity = (sum([Data{:}])/length([Data{:}]))*100;%average number of transmitted phonons in %
                     
    time = toc;
    
% which_dir = strcat(cd,'\Domain');
% dinfo = dir(which_dir);
% dinfo([dinfo.isdir]) = [];   
% filenames = fullfile(which_dir, {dinfo.name});
% delete( filenames{:} )

    load Run_number.mat
    Run_number = Run_number + 1;
    save('Run_number.mat','Run_number')
    filepath = cd;
%     filename = strcat('Elongation',num2str(num),'_tG',num2str(TransProb1),'_L',num2str(UnitCell(1)),'.mat');%,'_tDMM',num2str(TransProb2)
    filename = ['Circles_por',num2str(por),'L_',num2str(UnitCell(1).*num),'.mat'];
    save(strcat(filepath,'\DataBank\',filename))
    
%     poolobj = gcp('nocreate');
%     delete(poolobj);
%     
end