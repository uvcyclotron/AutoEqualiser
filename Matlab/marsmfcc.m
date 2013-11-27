%marsmfcc:  To be used in MFCC fn of MARS class.Calculates MFCC. Overwrites
%           the instance to one file, apppends to another.
fid = fopen('songlistnew.txt','r');
%song = fscanf(fid,'%s');

readdata = textscan(fid,'%s %s %s %s','Delimiter',';');

artiste = readdata{1};
song = readdata{2};
genre = readdata{3};
%songpath = readdata{4};

%songpath='D:\Data\Github\AutoEqualiser\Matlab\Johnny_B_Goode.wav'; 

[s,sr] = audioread('badomen.mp3');
smono = (s(:,1)+s(:,2)/2); 
dur = numel(smono)/sr;
snew = smono(floor(dur/3):floor(30*sr + (dur/3)),:);

% [s,sr] = wavread(songpath); %samples,sample rate output

% len = numel(s)/sr; %size of s/sample rate to get duration of track

% startt= floor(0.1*len);
% finisht = floor(startt + 30*sr);

% snew = wavread(songpath,[startt,finisht]);

zeroc = zerocros(snew);

Fmatrix = mfcc(snew,sr);
FMatMod=Fmatrix(:,3:end); #removed first 2 columns of trash values. mean works now.
MeanMFCC = mean(FMatMod,2);

fid = fopen('instance.txt','w');

%fprintf(tempfid,'%f,',MeanMFCC);
fprintf(fid,'%f,',MeanMFCC);

%fprintf(tempfid,'%s,',f);
fprintf(fid,'%f,',zeroc);

%fprintf(tempfid,'%s','UNKNOWN');
%fprintf(fid,'%s','?');

%fprintf(fid,'\n');

%fclose(tempfid);
fclose(fid);
%exit;