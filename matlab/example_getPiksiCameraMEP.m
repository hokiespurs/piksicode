%% example parse camera trigger
% *TSHUTTER IS PROBABLY WRONG (1/100 piksi limit?)
fname = '../exampledata/0017-00000-msg.csv';
[tMEP, tshutter] = getPiksiCameraMEP(fname);
