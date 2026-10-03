tmr1 = timer('ExecutionMode','fixedSpacing','Period',60);
tmr1.TimerFcn = @(~,~) sendSyntheticFeaturesToThingSpeak();
tmr1.start();
