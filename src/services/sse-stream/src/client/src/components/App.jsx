import React, {useEffect, useState} from "react";
import config from './../config/config';
import BootstrapTable from 'react-bootstrap-table-next';
import 'react-bootstrap-table-next/dist/react-bootstrap-table2.min.css';


const App = () => {

  //---------------------------------------------------
  //state variables to hold our data:
  // employees = list of employees
  // listen = flag to avoid unnecessary re-renders/subs
  //---------------------------------------------------
  const [employees, setEmployees] = useState([]);
  const [listener, setListener] = useState(false);
  
  //-----------------------------------
  // hook to perform side effects
  // when data has changed! (re-render)
  //-----------------------------------
  useEffect(() => {


    if(!listener){

        //----------------------------------------------------
        // use the EventSource API to subscribe to our API events
        // more info on this api can be found in this link:
        // https://html.spec.whatwg.org/multipage/server-sent- 
        // events.html#the-eventsource-interface
        //----------------------------------------------------
        const sourceEvents = new EventSource(config.SUBSCRIBE_ENDPOINT);


        //----------------------------------------------------
        // if there are events, we are listening to the default
        // "message" event, but you can listen to custom events
        // as well. Here, we just repopulate the employees.
        //-----------------------------------------------------
        sourceEvents.onmessage = (sourceEvent) => {
            console.log(`raw data: ${sourceEvent.data}`);
            console.log(`parsed data: ${JSON.parse(sourceEvent.data)}`);
            setEmployees(JSON.parse(sourceEvent.data));
        };

        
        //----------------------------------------
        // turn on flag to avoid multiple renders 
        // and subscriptions
        //----------------------------------------
        setListener(true);
    }
    
  }, [employees, listener]);

  
  //----------------------------------------------------
  // Helper function for data structure manipulation. 
  // We could have built this object from the server
  // and just parse it here but this is for illustration
  // purposes only...
  //----------------------------------------------------
  const getEmployeesAsJSON = () => {
    if(!employees) { return [];}
    return employees.map((name, index) => {
       return {name: name, id: index }
    });
  }

 
  //---------------------------------------------
  // Helper function to render a bootstrap table2
  //---------------------------------------------
  const render = () => {

    const columns = [
        {
            dataField: 'id',
            text: 'Employee ID'
        }, 
        {
            dataField: 'name',
            text: 'Employee Name'
        }
    ];



    return <BootstrapTable keyField='id' data={ getEmployeesAsJSON() } columns={ columns } />
  }


  return (
   <div className="d-flex justify-content-center mt-5">
    <div className="w-75">
        {render()}
    </div>
   </div>
  );
};


export default App;