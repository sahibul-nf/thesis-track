package utils

type Response struct {
	Error interface{} `json:"errors"`
	Data  interface{} `json:"data"`
}

type ResponseList struct {
	Error  interface{} `json:"errors"`
	Total  int         `json:"total"`
	Href   string      `json:"href"`
	Next   *string     `json:"next,omitempty"`
	Prev   *string     `json:"prev,omitempty"`
	Limit  int         `json:"limit"`
	Offset int         `json:"offset"`
	Data   interface{} `json:"data"`
}

// ResponseFormatter is a function to format API response to JSON format with meta, data, and error fields
func ResponseFormatter(data interface{}, err interface{}) interface{} {
	response := Response{
		Error: err,
		Data:  data,
	}

	return response
}

// ResponseFormatterList is a function to format API response to JSON format with meta, data, and error fields
func ResponseFormatterList(res ResponseList) interface{} {
	response := res

	return response
}
