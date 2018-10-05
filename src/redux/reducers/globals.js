import Immutable from 'seamless-immutable';
import { createReducer } from 'reduxsauce';
import ActionTypes from '@redux/actions/actionTypes';

const initialState = Immutable({ 
  loggedStatus : 0,
});

const setLoginStatus = function(state, action) {
    console.log('Saving Login Status.....');
    return ({
      ...state,
      loggedStatus : action.loginStatus,
    });
};

const actionHandlers = {
  [ActionTypes.SET_LOGIN_STATUS]: setLoginStatus,
}

export default createReducer(initialState, actionHandlers);