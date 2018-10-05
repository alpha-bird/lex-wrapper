import ActionType from '@ActionTypes';

export const setLoginStatus = loginStatus => ({
    type : ActionType.SET_LOGIN_STATUS, loginStatus
});