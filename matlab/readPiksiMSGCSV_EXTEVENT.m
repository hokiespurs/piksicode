function [t, istgood, isfalling] = readPiksiMSGCSV_EXTEVENT(strid, strlines)
%% Parse the PIKSI External Events from data parsed with (readPiksiMSGCSV)
ind = cellfun(@(x) strcmp(x,'EXT-EVENT'),strid);

eventlines = strlines(ind)';

t = cellfun(@(x) getLineNum(x,6),eventlines);
istgood = cellfun(@(x) getIsGood(x),eventlines);
isfalling = cellfun(@(x) getIsFalling(x),eventlines);

end

function n = getLineNum(x,columnnum)
dat = strsplit(x,',');
if numel(dat)>=columnnum
    n = str2double(dat(columnnum));
else
    n = NaN;
end

end

function id = getIsGood(x)
dat = strsplit(x,{',','|'});
if numel(dat)>3
    isgoodstr = dat{7};
else
    isgoodstr = '';
end
id = strcmp(isgoodstr,'Time: Good ');

end

function id = getIsFalling(x)
dat = strsplit(x,{',','|'});
if numel(dat)>3
    isgoodstr = dat{8};
else
    isgoodstr = '';
end
id = strcmp(isgoodstr(1:11),' Edge: Fall');

end