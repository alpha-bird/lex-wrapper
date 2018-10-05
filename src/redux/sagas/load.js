import { put, call, fork, takeLatest,takeEvery } from 'redux-saga/effects';
import ActionTypes from '@redux/actions/actionTypes';
import { LoadApi } from '@api/load';

function* runLoad(action) {
    try {
        const loaded = yield call( LoadApi );
        console.log(loaded);

        yield put(
            {
                type: ActionTypes.LOAD_SUCCESS,
                payload: {
                    todos: loaded
                },
            }
        );
    } catch (error) {
        yield put(
            {
                type: ActionTypes.LOAD_FAILED,
                payload: {
                    error,
                },
            }
        );
    }
}

export default function* loadSG() {
    console.log('Loading Saga');
    yield takeEvery( ActionTypes.LOAD_REQUEST, runLoad );
}