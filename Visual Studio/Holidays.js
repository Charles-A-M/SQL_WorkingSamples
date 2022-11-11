
/*		Returns an array of holidays with date and event. 
		inputs: Year, true=Federal only, false=all holidays, true=actual, false=actual and observed (closest weekday for weekend holidays).  */
function getHolidays(inYear, blnOnlyFederal = false, blnShowObserved = false) {
	let allHolidays = [];
	/*
		var HolidayNames = ["New Year's Day", "Martin Luther King Day", "Good Friday", "Memorial Day", "Independence Day", "Labor Day", "Thanksgiving Day", "Day After Thanksgiving", "Christmas Eve", "Christmas Day"]
		var Holidays = [new Date(i, 0, 1), new Date(getXDay(i, 1, 1, 3)), new Date(good), new Date(getXDay(i, 5, 1, -1)), new Date(i, 6, 4), new Date(getXDay(i, 9, 1, 1)), new Date(getXDay(i, 11, 4, 4)), new Date(getXDay(i, 11, 5, 4)), , new Date(i, 12, 24), new Date(i, 12, 25)];
	for (let i=inYear -1; i<inYear +1; i++) {
		var easter = getEaster(i);
		var good = new Date(easter);
		good.setDate(good.getDate() - 2);	
		var Holidays = [new Date(i, 0, 1), new Date(getXDay(i, 1, 1, 3)), new Date(good), new Date(getXDay(i, 5, 1, -1)), new Date(i, 6, 4), new Date(getXDay(i, 9, 1, 1)), new Date(getXDay(i, 11, 4, 4)), new Date(getXDay(i, 11, 5, 4)), , new Date(i, 12, 24), new Date(i, 12, 25)];
		
		for (let x=0; x<HolidayNames.length; x++) {
			
			var thisHoliday = HolidayObject(Holidays[x].getFullYear(), Holidays[x].getMonth() +1, Holidays[x].getDate(), HolidayNames[x]);
			var thisHolidayObs = HolidayObject(true, thisHoliday, false);
			allHolidays.push(thisHoliday);
			if (thisHolidayObs != null) { allHolidays.push(thisHolidayObs); }
 		
		}
	
	}

	*/

	/* holidays that are set dates and don't have Observed shifts */
	allHolidays.push(HolidayObject(inYear, 7, 4, "* Independence Day"));
	if (inYear > 2020) {
		allHolidays.push(HolidayObject(inYear, 6, 17, "* Juneteenth National Independence Day"));
	}
	allHolidays.push(HolidayObject(inYear, 11, 11, "* Veteran's Day"));
	
	/* Holidays on set dates that do have Observed shifts */
	var newYrs = HolidayObject(inYear, 1, 1, "* New Year's Day")
	var newYrsObs = checkObserved(blnShowObserved, newYrs, blnOnlyFederal);
	var Xmas = HolidayObject(inYear, 12, 25, "* Christmas Day");
	var XmasObs = checkObserved(blnShowObserved, Xmas, blnOnlyFederal);
	allHolidays.push(newYrs);
	allHolidays.push(Xmas);	
	if (newYrsObs != null) {allHolidays.push(newYrsObs) };
	if (XmasObs != null) { allHolidays.push(XmasObs); }
	
	/* Holidays based on Xth weekday of Month */
	var d = getXDay(inYear, 1, 1, 3);
	if (d != null) {allHolidays.push(HolidayObject(inYear, 1, d.getDate(), '* Martin Luther King Jr. Day')); }
	d = getXDay(inYear, 2, 1, 3);
	if (d != null) {allHolidays.push(HolidayObject(inYear, 2, d.getDate(), "* President's Day")); }
	d = getXDay(inYear, 5, 1, -1);
	if (d != null) {allHolidays.push(HolidayObject(inYear, 5, d.getDate(), "* Memorial Day")); }
	d = getXDay(inYear, 9, 1, 1);
	if (d != null) {allHolidays.push(HolidayObject(inYear, 9, d.getDate(), "* Labor Day")); }	
	d = getXDay(inYear, 10, 1, 2);
	if (d != null) {allHolidays.push(HolidayObject(inYear, 10, d.getDate(), "* Columbus Day")); }	
	d = getXDay(inYear, 11, 4, 4);
	if (d != null) {allHolidays.push(HolidayObject(inYear, 11, d.getDate(), "* Thanksgiving Day")); }	
	
	if (blnOnlyFederal != true) {
		/*	Holidays that aren't federal holidays, but are often observed in some way in the US */
			
		allHolidays.push(HolidayObject(inYear, 2, 14, "Valentine's Day"));
		allHolidays.push(HolidayObject(inYear, 3, 17, "Saint Patrick's Day"));
		allHolidays.push(HolidayObject(inYear, 10, 31, "Halloween"));
		var xMasEve = HolidayObject(inYear, 12, 24, "Christmas Eve");
		var xMasEveObs = checkObserved(blnShowObserved, xMasEve, blnOnlyFederal);
		allHolidays.push(xMasEve);
		if (xMasEveObs != null) { allHolidays.push(xMasEveObs); }
		allHolidays.push(HolidayObject(inYear, 12, 31, "New Year's Eve"));
		
		var easter = getEaster(inYear);
		if (easter != null) {
			var palm = new Date(easter);
			var maun = new Date(easter);
			var good = new Date(easter);
			palm.setDate(palm.getDate() - 7);
			maun.setDate(maun.getDate() - 3);
			good.setDate(good.getDate() - 2);
			allHolidays.push(HolidayObject(inYear, palm.getMonth() +1, palm.getDate(), 'Palm Sunday'));
			allHolidays.push(HolidayObject(inYear, maun.getMonth() +1, maun.getDate(), 'Maundy Thursday'));
			allHolidays.push(HolidayObject(inYear, good.getMonth() +1, good.getDate(), 'Good Friday'));
			allHolidays.push(HolidayObject(inYear, easter.getMonth() +1, easter.getDate(), 'Easter Sunday'));
		}
		
		d = getXDay(inYear, 5, 0, 2);
		if (d != null) {allHolidays.push(HolidayObject(inYear, 2, d.getDate(), "Mother's Day")); }
		d = getXDay(inYear, 6, 0, 3);
		if (d != null) {allHolidays.push(HolidayObject(inYear, 2, d.getDate(), "Father's Day")); }
		
		if (inYear < 2021) {
			allHolidays.push(HolidayObject(inYear, 6, 17, "Juneteenth National Independence Day"));
		}
	}
	
	allHolidays.sort((a, b) => a.date - b.date);
	
	return allHolidays;
}


/*
	US Holidays
	(* denotes Federal Holiday)
	- yyyy-01-01        : * New Year's Day
	- yyyy-01-(3rd Mon) : * Martin Luther King Jr. Day
	- yyyy-02-14        : Valentine's Day
	- yyyy-02-(3rd Mon) : * President's Day
	- yyyy-03-17        : Saint Patrick's Day
	- See below		    : Palm Sunday				(Sun before Easter)
	- See below		    : Maundy Thursday			(Thu before Easter)
	- See Below         : Good Friday 				(Fri before Easter)
	- See Below         : Easter
	- yyyy-05-(2nd Sun) : Mother's Day	
	- yyyy-05-(Last Mon : * Memorial Day
	- yyyy-06-19        : * Juneteenth 				(year 2021+)
	- yyyy-06-(3rd Sun) : Father's Day	
	- yyyy-07-04        : * Independence Day
	- yyyy-09-(1st Mon) : * Labor Day
	- yyyy-10-(2nd Mon) : * Columbus Day
	- yyyy-10-31        : Halloween
	- yyyy-11-11        : * Veterans Day
	- yyyy-11-(4th Thu) : * Thanksgiving Day
	- yyyy-12-25        : * Christmas Day
 	- yyyy-12-31        : New Year's Eve

https://en.wikipedia.org/wiki/Date_of_Easter

Easter falls on the first Sunday after the ecclesiastical full moon that occurs on or soonest after 21 March.					

*/

/* find the date of Easter Sunday for a given year */
function getEaster(inYr) {
	if (inYr < 1600 | inYr > 2400) { return null; }
	/*
	https://en.wikipedia.org/wiki/Date_of_Easter
	Easter falls on the first Sunday after the ecclesiastical full moon that occurs on or soonest after 21 March.
	from the New Scientist algorithm on the above website 	
	*/
	const a = inYr % 19;
	const b = Math.floor(inYr / 100);
	const c = inYr % 100;
	const d = Math.floor(b / 4);
	const e = b % 4;
	const g = Math.floor((8 * b + 13) / 25);
	const h = (19 * a + b - d - g + 15) % 30;
	const i = Math.floor(c / 4);
	const k = c % 4;
	const l = (32 + 2 * e + 2 * i - h - k) % 7;
	const m = Math.floor((a + 11 * h + 19 * l) / 433);
	const n = Math.floor((h + l - 7 * m + 90) / 25);
	const p = (h + l - 7 * m + 33 * n + 19) % 32;
 
	return new Date(inYr, n - 1, p);	
}


/*	creates an jobect. reference contents as:
	holiday.dateText -- yyyy-mm-dd, holiday.date, holiday.description.
	to make this easier to align with holiday lists, this accepts the new date as calendar month (1-12), not JavaScript month (0-11).	*/
function HolidayObject(inYear, inMonth, inDay, inHolidayText) {
	var days =  [' (Sun)',' (Mon)',' (Tue)',' (Wed)',' (Thu)',' (Fri)',' (Sat)'];

	const dt = new Date(inYear, inMonth -1, inDay);
	
	const holiday = {
		dateText: inYear + '-' + ('00' + inMonth).slice(-2) + '-' + ('00' + inDay).slice(-2) + days[ dt.getDay() ],
		date: dt,
		description: inHolidayText
	};
	
	return holiday;
}


/*	if blnShowObsered, check the holiday's date. If it's Sat or Sun, shift the date back or forward.
	If it's Christmas Eve / Christmas, make sure we don't have 2 holidays on the same date.
	Return holiday object (holiday.description + " observed"). Or return null. */
function checkObserved(blnShowObsered, thisHoliday, blnOnlyFederal) {
	var thisDate = thisHoliday.date;
	var newDate = null;
	
	if (blnShowObsered != true) { return null; }	

	if (thisDate.getDay() == 0) {  /* Sunday; roll forward */
		newDate = new Date(thisDate.getFullYear(), thisDate.getMonth(), thisDate.getDate());
 
		if (thisDate.getDate() == 24 & thisDate.getMonth() == 11 & blnOnlyFederal != true) {
			newDate.setDate(newDate.getDate() + 2);
		} else {
			newDate.setDate(newDate.getDate() + 1);
		}
	} else if (thisDate.getDay() == 6) { /* Saturday; roll backward */
		newDate = new Date(thisDate.getFullYear(), thisDate.getMonth(), thisDate.getDate());
				
		if (thisDate.getDate() == 25 & thisDate.getMonth() == 11 & blnOnlyFederal != true) {
			newDate.setDate(newDate.getDate() - 2);
		} else {
			newDate.setDate(newDate.getDate() - 1);
		}
	} 
	if (newDate == null) { return null; }
 
	return HolidayObject(newDate.getFullYear(), newDate.getMonth() + 1, newDate.getDate(), thisHoliday.description + ' Observed');
}


/*
	Returns a date that is the Xth weekday of the given month.
	use a negative Xth value to count back from end of the month 
	  so -1 would be last, -2 2nd to last, etc.  */
function getXDay(inYear, inMonth, inWeekDay, inXth) {
	if (inXth > 5 | inXth < -5 | inXth == 0) { return null; }
	if (inMonth < 1 | inMonth > 12) { return null; }
	if (inWeekDay < 0 | inWeekDay > 6) { return null; }
	
	var d ;
	var incBy = 0;
	var wkDayCounter = 0;
	
	/* are we finding the 1st or last? */
	if (inXth > 0) {
		d = new Date(inYear, inMonth - 1, 1);
		incBy = 1;
	} else if (inXth < 0) {
		d = new Date(inYear, inMonth, 1);
		d.setDate(d.getDate() -1);
		incBy = -1;
	}	
		
	while (inMonth - 1  == d.getMonth()) {
		if (d.getDay() == inWeekDay) {
			wkDayCounter++;
			if (wkDayCounter == Math.abs(inXth)) {
				return d;
			}
		}
		d.setDate(d.getDate() + incBy);			
	}
	return null;
}



