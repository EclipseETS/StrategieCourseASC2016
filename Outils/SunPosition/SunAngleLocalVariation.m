%SunAngleVariation
clear
%Location
loc_llh(1)=45.6966; % PittRace
loc_llh(2)=-73.8736; % PittRace
loc_llh(3)=0;
loc_llh=loc_llh(:);

%Local Time to julian day start
Y=2014; M=0; D=0; H=0; MI=0; S=0;
Marker{1}='b';
Marker{2}='r';
UT_offset =8; %-longitude/15
figure
m=0;
for M=[0,6]
    m=m+1;
    jday0=julian([Y,M,D,H,MI,S],UT_offset);
    minutes_day=24*60;
    jday=jday0+(0:minutes_day-60)/minutes_day-0.3;
    sun=sun_positionR(jday,loc_llh);
    
    zenith=sun.zenith;
    azimuth=sun.azimuth;
    
    subplot(2,1,1)
    hold on
    plot((jday-jday0)*24+8,90-zenith,Marker{m})
    grid on
    axis([0,25, 0 90])
    ylabel('Elevation-deg')
    title('Local Solar Angle (NORCAL)')
    subplot(2,1,2)
    hold on
    plot((jday-jday0)*24+8,azimuth,Marker{m})
    grid on
    ylabel('Azimuth-deg')
    xlabel('Local Time-hrs')
end
subplot(2,1,1)
legend('Winter','Summer')