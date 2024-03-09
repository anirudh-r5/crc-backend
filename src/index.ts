import {
	APIGatewayEvent,
	APIGatewayProxyResult,
	Context,
	Handler,
} from 'aws-lambda';
import {
	DynamoDBDocumentClient,
	GetCommand,
	GetCommandOutput,
	UpdateCommand,
} from '@aws-sdk/lib-dynamodb';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { marshallOptions, unmarshallOptions } from './util/marshal.js';

const marshallOptions: marshallOptions = {
	convertEmptyValues: false,
	removeUndefinedValues: false,
	convertClassInstanceToMap: true,
	convertTopLevelContainer: true,
};
const unmarshallOptions: unmarshallOptions = {
	wrapNumbers: false,
	convertWithoutMapWrapper: true,
};
const client = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(client, {
	marshallOptions,
	unmarshallOptions,
});
const tableName: string = 'CrcBackendMetadata';

const createAttribute = async () => {
	const count = await ddbDocClient.send(
		new UpdateCommand({
			TableName: tableName,
			Key: {
				metaId: 'globalViewCount',
			},
			UpdateExpression: 'SET val = :count',
			ExpressionAttributeValues: {
				':count': 1,
			},
			ReturnValues: 'UPDATED_OLD',
		}),
	);
	return count.Attributes?.value;
};
const updateCount = async () => {
	await ddbDocClient.send(
		new UpdateCommand({
			TableName: tableName,
			Key: {
				metaId: 'globalViewCount',
			},
			UpdateExpression: 'SET val = val + :count',
			ExpressionAttributeValues: {
				':count': 1,
			},
		}),
	);
};
export const handler: Handler = async (
	event: APIGatewayEvent,
	context: Context,
): Promise<APIGatewayProxyResult> => {
	console.log(`Event: ${JSON.stringify(event, null, 2)}`);
	console.warn(`Context: ${JSON.stringify(context, null, 2)}`);
	const viewCount: GetCommandOutput = await ddbDocClient.send(
		new GetCommand({
			Key: { metaId: 'globalViewCount' },
			TableName: tableName,
		}),
	);
	if (!viewCount.Item) {
		await createAttribute();
		return {
			statusCode: 200,
			body: JSON.stringify({
				message: 1,
			}),
		};
	} else {
		await updateCount();
		return {
			statusCode: 200,
			body: JSON.stringify({
				message: viewCount.Item?.val,
			}),
		};
	}
};
