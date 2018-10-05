import { combineReducers } from 'redux';
import { NavigationActions } from 'react-navigation';
import PropTypes from 'prop-types';
import globals from './globals';

const AppReducer = combineReducers({
  globals,
});

export default AppReducer;