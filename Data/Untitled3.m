SC = [1 2 3];
plotPerSubject(final.data, SC);

percentAbortBlock(final.data, 1);

replace = cleaned.allDataFree (:,10);
cleaned.allDataFree   = horzcat(cleaned.allDataFree , replace)
cleaned.allDataFree (:,10) = [];
cleaned.allDataFree= cleaned.allData;
plotPerSubject(cleaned.allDataFree, 4);
pcFR(cleaned.allDataFree, 4, 0);