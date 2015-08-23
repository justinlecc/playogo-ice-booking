// retrieves info from the schedule_tree
function getFromScheduleTree(schedule_tree, item, venue, theatre) {

  var returnValue = false;

  if ('prime' == item || 'non_prime' == item || 'insurance' == item) {

    _.each(schedule_tree.venues, function (iter_venue) {

      if (venue == iter_venue.name) {

        _.each(iter_venue.theatres, function (iter_theatre) {

          if (theatre == iter_theatre.name) {



            if ('prime' == item){
            
              returnValue = iter_theatre.prime;

            } else if ('non_prime' == item) {

              returnValue = iter_theatre.non_prime;

            } else if ('insurance' == item) {

              returnValue = iter_theatre.insurance;

            } else {

              throw "ERROR: unrecognized item type in getFromScheduleTree";

            }
            
          }
        })
      }
    })
  }

  if (!returnValue) {

    throw 'ERROR: did not find matching venue and theatre';

  }

  return returnValue;

};