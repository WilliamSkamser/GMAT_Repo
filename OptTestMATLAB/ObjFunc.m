function e=ObjFunc(ThrustProfileNew)
%WRITE New Thrust File
Headerlines=6;
file2='C:/GMAT_Repo/OptTestMATLAB/ThrustProfile.thrust';
S = fileread(file2);
SS = regexp(S, '\r?\n', 'split');
for i=1:10
    LineToChange = i+Headerlines; 
    NewContent = compose("%.1f     \t%.3f %.3f %.3f  0.001",ThrustProfileNew(i,1),ThrustProfileNew(i,2),ThrustProfileNew(i,3),ThrustProfileNew(i,4));
    SS{LineToChange} = NewContent;
end
fid2 = fopen(file2, 'w');
fprintf(fid2, '%s\n', SS{:});
fclose(fid2);

%RUN GMAT Script With New Thrust File
load_gmat();
Ans1=gmat.gmat.LoadScript("../OptTestMATLAB/OptTestMatlab.script");
if Ans1 == 1
    Ans2=gmat.gmat.RunScript();
    if Ans2 == 0
        fprintf("Fail to run script");
    end
else
    fprintf("Fail to load script\n");
end

%READ Data File
file1='C:/GMAT_Repo/OptTestMATLAB/DataReport.txt';
fID1=fopen(file1,'r');
B=textscan(fID1, '%f %f %f %f', 'headerlines',1);
Data=cell2mat(B);
fclose(fID1);

e=Data(1); %eccentricity  
end