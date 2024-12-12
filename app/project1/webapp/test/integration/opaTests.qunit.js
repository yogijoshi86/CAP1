sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'project1/test/integration/FirstJourney',
		'project1/test/integration/pages/time_attendance_reportingList',
		'project1/test/integration/pages/time_attendance_reportingObjectPage'
    ],
    function(JourneyRunner, opaJourney, time_attendance_reportingList, time_attendance_reportingObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('project1') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onThetime_attendance_reportingList: time_attendance_reportingList,
					onThetime_attendance_reportingObjectPage: time_attendance_reportingObjectPage
                }
            },
            opaJourney.run
        );
    }
);