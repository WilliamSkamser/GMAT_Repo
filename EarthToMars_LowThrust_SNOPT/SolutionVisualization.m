function [Data,Thrust,TOF] = SolutionVisualization(x)
global NumberOfSteps
global Th
global mdot
global TU
global my_dir
global headlines

% Extract Design Variables
Thrust_alpha = x(1:NumberOfSteps);                   % rads
Thrust_beta = x(NumberOfSteps+1:2*NumberOfSteps);   % rads
TOF     = x(end)*TU;                                           % s
ThrustVec=Th.*[cos(Thrust_beta).*cos(Thrust_alpha),cos(Thrust_beta).*sin(Thrust_alpha),sin(Thrust_beta)];
%% Create Thrust History 
Thrust = zeros(NumberOfSteps+1,3);
Thrust(1:(end-1),:)=ThrustVec;

% Obtain time History
Time = linspace(0,TOF,NumberOfSteps+1)';  % seconds

% % Obtain Mass History
% mass = zeros(length(Time),1);    mass(1)= m0;
% for i=2:length(Time)
%     mass(i) = mass(i-1)*exp(-1/Vex*abs(trapz(Time(i-1:i),[norm(ThrustAcc(i-1,:));norm(ThrustAcc(i,:))]*1000)));
% end
% 
% % Create Thrust Profile
% Thrust = mass.*ThrustAcc*1000; % N or kg m/s^2
% Thrust = ThrustAcc*1000;

%% Write Thrust History File

% Obtain the Iter number and append it with the Thrust File
file2  = 'ThrustProfileSolution.thrust'; 

% Create the file in the folder as specified
file2 = fullfile(my_dir,file2); 

% Write the contents of the Thrust File
for i=1:NumberOfSteps+1
    LineToChange = i+1;         % first 6 lines ae used for headers
    NewContent = compose("%.16f \t %.16f %.16f %.16f %.16f",Time(i),Thrust(i,1),Thrust(i,2),Thrust(i,3),mdot);
    SS{LineToChange} = NewContent;
end
fid2 = fopen(file2, 'w');
fprintf(fid2,'%s',headlines);
fprintf(fid2, '%s\n', SS{:});
fprintf(fid2,'%s','EndThrust{ThrustSegment1}');
fclose(fid2);

%WRITE Thrust Run Time
file3='../EarthToMars_LowThrust_SNOPT/ThrustRunTime.txt';
fid3 = fopen(file3, 'w');
fprintf(fid3, '%.16d', TOF);
fclose(fid3);

%% RUN GMAT and Read the Results

% Load GMAT
load_gmat();

% Load GMAT SCRIPT
gmat.gmat.LoadScript("C:/GMAT_Repo/EarthToMars_LowThrust_SNOPT/GMATScriptEarthMarsPlots.script");

% Input the TOF as RunTime
%PropTime = gmat.gmat.GetObject('RunTime');
%PropTime.SetField('Value', TOF);

% Input the Location of the Corresponding Thrust File
%Thrust_File = gmat.gmat.GetObject('ThrustHistoryFile1');
%Thrust_File.SetField('FileName',file2);

% Run GMAT Script
Ans = gmat.gmat.RunScript();

%READ Data File
file1='../EarthToMars_LowThrust_SNOPT/DataOutput.txt';
fID1=fopen(file1,'r');
B=textscan(fID1, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines',1);
Data=cell2mat(B);
fclose(fID1);
end