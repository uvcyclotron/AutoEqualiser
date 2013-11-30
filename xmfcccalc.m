%marsmfcc:  To be used in MFCC fn of MARS class.Calculates MFCC. Overwrites
%           the instance to one file, apppends to another.
fid = fopen('songlist.txt','r');  %changed,should be songlist.txt
%song = fscanf(fid,'%s');

readdata = textscan(fid,'%s %s %s %s','Delimiter',';');

artiste = readdata{1};
song = readdata{2};
genre = readdata{3};
songpath = readdata{4};

disp(2)
fid = fopen('genre_test.csv','w');
for i=105:135 %184 songs for testing 
    
    [s,sr] = audioread(songpath{i}); %this works, nw write loop to take each line from songpath, run, append to a csv rather than new csv for each song
    smono = (s(:,1)+s(:,2)/2);
    dur = numel(smono)/sr;
    snew = smono(floor(dur/3):floor(30*sr + (dur/3)),:);
    
    % [s,sr] = wavread(songpath);
    
    % len = numel(s)/sr;
    
    % startt= floor(0.1*len);
    % finisht = floor(startt + 30*sr);
    
    % snew = wavread(songpath,[startt,finisht]);
    
    summatrix = zeros((floor(numel(snew)/512)+1));
    for i=1:512:numel(snew)
        if (i+512<numel(snew))
            tempmat = snew(i:i+512);
        else
            tempmat = snew(i:end);
        end
        
        zeroc_wrep = zerocros(tempmat);
        zeroc_worep = unique(zeroc_wrep);
        zeroc = numel(zeroc_worep);
        
        summatrix(floor(i/512)+1) = zeroc;
    end
    
    avg_zeroc = mean(summatrix);
    
    %spec_cent = centroid()
    
    Fmatrix = mfcc(snew,sr);
    % FMatMod=zeros(13);
    % FMatMod=FMatMod(:,1);
    % for i=1:numel(Fmatrix)
    %     if(~isnan(Fmatrix(1,i)) && ~isinf(Fmatrix(1,i)))  %top of column should be neither NaN nor Inf
    %         FMatMod=FMatrix(i);
    %
    %     end
    % end
    i=1;
    while (isnan(Fmatrix(1,i)) || isinf(Fmatrix(1,i)))
        
        i=i+1;
    end
    
    FMatMod=Fmatrix(:,i:end); %1st 2 columns were trash values, so ignoring them
    MeanMFCC = mean(FMatMod,2); %using the modified mat produces mean values.
    
    
    
    fprintf(fid,'%f,',avg_zeroc(1));
    %fprintf(tempfid,'%f,',MeanMFCC);
    fprintf(fid,'%f,',MeanMFCC(1:12));
    fprintf(fid,'%f\n',MeanMFCC(13));
    disp(i+' done');
    %fprintf(tempfid,'%s,',f);
    
    %fprintf(tempfid,'%s','UNKNOWN');
    %fprintf(fid,'%s','?');
    
    %fprintf(fid,'\n');
end
%fclose(tempfid);
fclose(fid);
%exit;