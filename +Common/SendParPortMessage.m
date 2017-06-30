function SendParPortMessage( S, EP )

if strcmp( S.ParPort , 'On' )
    
    pp = msg.(EP.Data{evt,1});
    
    % Send Trigger
    WriteParPort( pp );
    WaitSecs( msg.duration );
    WriteParPort( 0 );
    
end

end % function
