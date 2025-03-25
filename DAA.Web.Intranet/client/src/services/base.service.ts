import axios from 'axios';

class BaseService {
    private CancelToken = axios.CancelToken;
    
    private _source = this.CancelToken.source();
    
    private _abortController = new AbortController();

    // private _abortSignal = new AbortSignal();
        
    get source() {
        return this._source;
    }

    get abortController() {
        return this._abortController;
    }
    get abortSignal() {
        return this.abortController.signal;
    }

    cancelAxiosToken() {
        this._source.cancel();
        this._source = axios.CancelToken.source();
    }

    initAbortController() {
        this._abortController = new AbortController();
    }

    abort() {
        this._abortController.abort();
    }
}
export default BaseService;
