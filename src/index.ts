import {
  APIGatewayEvent,
  APIGatewayProxyResult,
  Context,
  Handler,
} from 'aws-lambda';

export const handler: Handler = async (
  event: APIGatewayEvent,
  context: Context,
): Promise<APIGatewayProxyResult> => {
  console.log(`Event: ${JSON.stringify(event, null, 2)}`);
  console.warn(`Context: ${JSON.stringify(context, null, 2)}`);
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "yo what's up?",
    }),
  };
};
