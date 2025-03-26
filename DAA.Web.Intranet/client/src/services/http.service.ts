/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable no-unused-vars */
/* eslint-disable no-async-promise-executor */
/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import { appStore as useAppStore } from '@/store/app';
import { userStore as useUserStore } from '@/store/user';
import router from '@/router';
import { ActionTypes } from '@/store/user/actions';
import axios, { AxiosRequestConfig, AxiosResponse, AxiosStatic } from 'axios';
//import { AuthType } from '@/models/auth';
//import messageService, { IMessage, IMessageOptions } from '@/services/message.service';

const userStore = useUserStore();
const appStore = useAppStore();
export class Http {
    /**
     * Get axios instance if additional configuration is needed
     */
    get axiosInstance(): AxiosStatic { return axios }

    /**
     * HTTP GET request
     * Returns Promise
     * @param url String representation of url
     * @param type Typescript class type. Optional.
     * @param useConstructor boolean (default false). Indicates if we want to use class constructor (true) or use default constructor (false). Optional.
     * @param config AxiosRequestConfig. Additional axios configuration. Optional.
     */
    public get<T>(url: string, type?: (new (arg: any) => T), useConstructor?: boolean, config?: AxiosRequestConfig): Promise<any> {
        if (type) {
            return new Promise(async (resolve, reject) => {
                try {
                    const { data } = await axios.get(url, config);
                    return resolve(this.parseData(type, data, useConstructor));
                } catch (error) {
                    return reject(error);
                }
            })
        } else {
            //if there is no type, return axios default behavior
            return axios.get(url, config);
        }
    }

    /**
     * HTTP DELETE request
     * Returns Promise
     * @param url String representation of url
     * @param type Typescript class type.Optional.
     * @param useConstructor boolean (default false). Indicates if we want to use class constructor (true) or use default constructor (false).Optional.
     * @param config AxiosRequestConfig | undefined. Additional axios configuration.Optional.
     */
    public delete<T>(url: string, type?: (new (arg: any) => T), useConstructor?: boolean, config?: AxiosRequestConfig | undefined): Promise<any> {
        if (type) {
            return new Promise(async (resolve, reject) => {
                try {
                    const { data } = await axios.delete(url, config);
                    return resolve(this.parseData(type, data, useConstructor));
                } catch (error) {
                    return reject(error);
                }
            })
        } else {
            //if there is no type, return axios default behavior
            return axios.delete(url, config);
        }
    }

    /**
     * HTTP POST request
     * Returns Promise
     * @param url String representation of url
     * @param type Typescript class type.Optional.
     * @param useConstructor boolean (default false). Indicates if we want to use class constructor (true) or use default constructor (false).Optional.
     * @param config AxiosRequestConfig | undefined. Additional axios configuration.Optional.
     */
    public post<T>(url: string, payload: any, type?: (new (arg: any) => T), useConstructor?: boolean, config?: AxiosRequestConfig | undefined): Promise<any> {
        if (type) {
            return new Promise(async (resolve, reject) => {
                try {
                    const { data } = await axios.post(url, payload, config);
                    return resolve(this.parseData(type, data, useConstructor));
                } catch (error) {
                    return reject(error);
                }
            });
        } else {
            //if there is no type, return axios default behavior
            return axios.post(url, payload, config);
        }
    }

    /**
     * HTTP PUT request
     * Returns Promise
     * @param url String representation of url
     * @param type Typescript class type.Optional.
     * @param useConstructor boolean (default false). Indicates if we want to use class constructor (true) or use default constructor (false).Optional.
     * @param config AxiosRequestConfig | undefined. Additional axios configuration.Optional.
     */
    public put<T>(url: string, payload: any, type?: (new (arg: any) => T), useConstructor?: boolean, config?: AxiosRequestConfig | undefined): Promise<any> {
        if (type) {
            return new Promise(async (resolve, reject) => {
                try {
                    const { data } = await axios.put(url, payload, config);
                    return resolve(this.parseData(type, data, useConstructor))
                } catch (error) {
                    return reject(error);
                }
            })
        } else {
            //if there is no type, return axios default behavior
            return axios.put(url, payload, config);
        }
    }

    /**
     * Creates response object
     * @param type Typescript class type to be returned
     * @param data Response data
     * @param useConstructor boolean (default false). Indicates if we want to use class constructor (true) or use default constructor (false)
     */
    private createObject(type: any, data: any, useConstructor: boolean = false): any {
        let result: any;

        if (useConstructor) {
            result = new type(data);
        } else {
            result = new type();
            for (const key in data) {
                if (Object.prototype.hasOwnProperty.call(result, key)) {
                    result[key] = data[key];
                }
            }
        }

        return result;
    }

    /**
     * Parse response data, before creating response object
     * @param type Typescript class type to be returned
     * @param data Response data
     * @param useConstructor boolean (default false). Indicates if we want to use class constructor (true) or use default constructor (false)
     */
    private parseData(type: any, data: any, useConstructor: boolean = false) {
        if (!data) {
            return;
        }

        if (data instanceof Array) {
            const result = data.map(x => this.createObject(type, x, useConstructor));
            return result;
        } else {
            const result = this.createObject(type, data, useConstructor);
            return result;
        }
    }
}

const http = new Http();

http.axiosInstance.interceptors.request.use((value: AxiosRequestConfig) => {
    value.baseURL = appStore.getters.baseUrl;
    //Auth token
    const token = userStore.getters.token;
    //CORS with Windows authentication requires { credentials : 'include' }
    const includeCredentials = true;
    value.withCredentials = includeCredentials;
    
    value.headers = value.headers ?? {};
    //Windows authentication does not work (infinity logon loop) with Bearer token, expects Negotiate token (applied by browser)
    if (token && !includeCredentials) {
        value.headers.Authorization = `Bearer ${token}`;
    }

    //Culture
    const lang = appStore.getters.language;
    value.headers["Accept-Language"] = lang || 'bg';
    value.headers["Accept"] = '*/*';
		value.headers["Access-Control-Allow-Origin"] = '*'

    if (!value.headers["Content-Type"]) {
        value.headers["Content-Type"] = 'application/json';
    }

    return value;
});

// Add a common error response interceptor
http.axiosInstance.interceptors.response.use((response: AxiosResponse) => {
    return response;
}, function (error: any) {
    if (error.response) {
        switch (error.response.status) {
            case 401:
                userStore.dispatch(ActionTypes.RemoveUser);
                router.push({ name: 'NotAuthorized'});
                break;
            case 403:
				//TODO това не препраща, а да излиза като съобщение
                router.push({ name: 'AccessDenied' });
                break;
            case 404:
				//TODO това не препраща, а да излиза като съобщение
                router.push({ name: 'NotFound'});
                break;
            case 400:
            case 500:
                console.error(error);
                break;
        }
        return Promise.reject(error.response.data);
    }
    return Promise.reject(error);
});

export default http;