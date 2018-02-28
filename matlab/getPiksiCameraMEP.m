function [tStart, tshutter] = getPiksiCameraMEP(fname)
%% return the start time (falling edge) + shutter duration (PROBABLY WRONG)

[strid, strlines] = readPiksiMSGCSV(fname);
[t, istgood, isfalling] = readPiksiMSGCSV_EXTEVENT(strid, strlines);

if mod(numel(t),2)==1
    error('Odd Number of Rising + Falling Edges... time lock during middle of exposure?');
end

if any(istgood==0)
   error('BAD TIME'); 
end

tCam = reshape(t,2,numel(t)/2)'; % row = one cam

tStart = tCam(:,1);
tshutter = tCam(:,2)-tCam(:,1);

end